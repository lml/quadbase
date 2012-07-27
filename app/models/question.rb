# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class Question < ActiveRecord::Base
  include AssetMethods
  include VariatedContentHtml
  
  acts_as_taggable
  
  @@lock_timeout = Quadbase::Application.config.question_lock_timeout

  self.inheritance_column = "question_type"
  
  has_many :question_collaborators, 
           :order => :position, 
           :dependent => :destroy
  has_many :collaborators, 
           :through => :question_collaborators,
           :source => :user
  has_many :list_questions, :dependent => :destroy

  belongs_to :license
  belongs_to :question_setup
  belongs_to :publisher, :class_name => "User"
  
  has_one :logic, :as => :logicable, :dependent => :destroy

  accepts_nested_attributes_for :question_setup, :logic
  
  has_one :question_source, 
          :class_name => "QuestionDerivation",
          :foreign_key => "derived_question_id"
  has_one :source_question, :through => :question_source
           
  has_many :question_derivations,
           :foreign_key => "source_question_id"
  has_many :derived_questions, :through => :question_derivations
    
  has_many :parent_question_parts, 
           :class_name => "QuestionPart",
           :foreign_key => :child_question_id,
           :dependent => :destroy
  has_many :multipart_questions, :through => :parent_question_parts
  
  has_many :attachable_assets, :as => :attachable, :dependent => :destroy
  has_many :assets, :through => :attachable_assets

  
  # Sometimes question A is required to be shown before question B.  In this
  # situation, question A is called a prerequisite of question B.  Question B
  # is called a dependent of question A.
  
  has_many :prerequisite_question_pairs,
           :class_name => "QuestionDependencyPair",
           :foreign_key => "dependent_question_id",
           :conditions => { :kind => "requirement" },
           :dependent => :destroy
  has_many :prerequisite_questions,
           :through => :prerequisite_question_pairs,
           :source => :independent_question
           
  has_many :dependent_question_pairs,
           :class_name => "QuestionDependencyPair",
           :foreign_key => "independent_question_id",
           :conditions => { :kind => "requirement" },
           :dependent => :destroy         
  has_many :dependent_questions,
           :through => :dependent_question_pairs
  
  # Sometimes if someone solves question A, it will be easier for them to solve
  # question B.  In this case, A is a supporting question to B.  B is a
  # supported question of A.
   
  has_many :supporting_question_pairs,
           :class_name => "QuestionDependencyPair",
           :foreign_key => "dependent_question_id",
           :conditions => { :kind => "support" },
           :dependent => :destroy
  has_many :supporting_questions,
           :through => :supporting_question_pairs,
           :source => :independent_question

  has_many :supported_question_pairs,
           :class_name => "QuestionDependencyPair",
           :foreign_key => "independent_question_id",
           :conditions => { :kind => "support" },
           :dependent => :destroy
  has_many :supported_questions,
           :through => :supported_question_pairs,
           :source => :dependent_question
           

  has_many :solutions, :dependent => :destroy

  has_many :questions_same_number,
           :class_name => "Question",
           :primary_key => "number",
           :foreign_key => "number"
  
  has_one :comment_thread, :as => :commentable, :dependent => :destroy
  before_validation :build_comment_thread, :on => :create
  validates_presence_of :comment_thread

  before_destroy :not_published

  after_destroy :destroy_childless_question_setup
  
  # Should hopefully prevent question setup from ever being nil
  before_validation :build_question_setup, :unless => Proc.new { |q| q.question_setup || q.is_published? }
  validates_presence_of :question_setup, :unless => :is_published?

  before_save :clear_empty_logic

  validate :not_published, :on => :update

  validates_presence_of :license
  before_validation :set_default_license!, :on => :create, :unless => :license

  before_create :assign_number

  scope :draft_questions, where{version == nil}
  scope :published_questions, where{version != nil}
  scope :questions_in_lists, lambda { |lists|
    joins{list_questions}.where{list_questions.list_id.in(lists.collect { |p| p.id })}
  }
  scope :user_list_questions, lambda { |user|
    joins{list_questions.list.list_members}\
      .where{list_questions.list.list_members.user_id == user.id}
  }
  scope :published_with_number, lambda { |num|
    published_questions.where{number == num}.order{updated_at.desc}
  }
  # Can read a question if any of those:
  #   - Question is published
  #   - User is a member or a list that contains the question
  #   - User is a question collaborator with roles
  #   - User is a deputy of a question collaborator with roles
  scope :which_can_be_read_by, lambda { |user|
    return published_questions if user.is_anonymous?
    joins{list_questions.outer.list.outer.list_members.outer}\
    .joins{question_collaborators.outer.user.outer.deputies.outer}\
    .where{(version != nil) |\
    (list_question.list.list_members.user_id == user.id) |\
    (((question_collaborators.user_id == user.id) |\
    (question_collaborators.user.deputies.id == user.id)) &\
    ((question_collaborators.is_author == true) |\
    (question_collaborators.is_copyright_holder == true)))}
  }

  # This type is passed in some questions params; we need an accessor for it 
  # even though we don't explicitly save it.
  attr_accessor :type
  
  # Disallow mass assignment for certain attributes that should only be
  # modifiable by the system (note that users can modify question_setup data
  # but we don't want them deciding which questions share setups, etc)
  # Using whitelisting instead of blacklisting here.
  attr_accessible :content, :changes_solution, :question_setup_attributes, 
                  :logic_attributes

  def to_param
    if is_published?
      "q#{number}v#{version}"
    else
      "d#{id}"
    end
  end
  
  def self.exists?(param)
    begin
      from_param(param)
      return true
    rescue
      return false
    end
  end

  def self.from_param(param)
    if (param =~ /^d(\d+)$/)
      q = Question.find($1.to_i) # Rails escapes this
    elsif (param =~ /^q(\d+)(v(\d+))?$/)
      if ($3.nil?)
        q = latest_published($1.to_i) # Rails escapes this
      else
        q = find_by_number_and_version($1.to_i, $3.to_i) # Rails escapes this
      end
    else
      raise SecurityTransgression
    end
    
    raise ActiveRecord::RecordNotFound if q.nil?
    q
  end
  
  def self.latest_published(number)
    Question.published_with_number(number).first
  end
  
  def prior_version
    has_earlier_versions? ? 
      Question.where{(number == my{number}) & (version == my{version - 1})}.first :
      nil
  end
    
  # Called to create the first-ever role for a question, where by default
  # the creator is given all three roles.  Must assign explicitly as the 
  # roles cannot be mass assigned for security reasons.
  def set_initial_question_roles(user)
    q = question_collaborators.create(:user => user)
    q.is_author = true
    q.is_copyright_holder = true
    q.save!
    comment_thread.subscribe!(user)
  end
  
  def run_prepublish_error_checks
    self.errors.add(:base, 'This question has pending role requests.') \
      if !question_role_requests.empty?

    self.errors.add(:base, 'The two question roles are not filled for this question.') \
      if !has_all_roles?
        
    self.errors.add(:base, 'A license has not yet been specified for this question.') \
      if !has_license?
    
    self.errors.add(:base, 'This question is already published.') \
      if is_published?
    
    self.errors.add(:base, 'Newer versions of this question already exist! ' + 
                          'Please start modifications again from the latest version.') \
      if superseded?
        
    # Test that the logic in this question runs successfully.  variate! already 
    # adds errors to self if there are any logic problems.
    variator = QuestionVariator.new(rand(2e8), true)
    variate!(variator)
    
    # If we don't have errors, run the variation again to make sure that the same content 
    # is generated for the same seed
    if self.errors.none?
      first_run_hash = variator.output_hash
      
      variator = QuestionVariator.new(variator.seed, true)
      variate!(variator)
      second_run_hash = variator.output_hash
      
      self.errors.add(:base, 'This question produced different content for the same seed; this is not allowed.') \
        if first_run_hash != second_run_hash
    end
        
    add_other_prepublish_errors
  end
  
  # A template method allowing child classes to add to the errors that must
  # be corrected before publishing will be allowed
  def add_other_prepublish_errors 
  end
  
  def ready_to_be_published?
    run_prepublish_error_checks  
    self.errors.empty?    
  end
  
  def publish!(user)
    return if !ready_to_be_published?
    
    # This hook allows child classes to implement class-specific code that
    # should run before publishing
    run_prepublish_hooks(user)

    roleless_collaborators.each { |rc| rc.destroy }
    comment_thread.clear!
    comment_thread(true) # because .clear! makes new thread!
    
    question_collaborators.each do |qc|
      comment_thread.subscribe!(qc.user) if (qc.has_role?(:author) && 
                                             qc.user.user_profile.auto_author_subscribe)
    end
    
    self.version = next_available_version
    self.publisher = user

    # Do some cleanup
    # Can only really be exactly in this position so no longer a function
    if question_setup.is_empty?
      setup = self.question_setup
      self.question_setup = nil
    end
    self.save!
    setup.destroy_if_unattached if self.question_setup.nil?
  end
  
  def is_published?
    nil != version
  end
  
  def content_change_allowed?
    !is_published?
  end  
  
  def setup_is_changeable?
    !is_published? && question_setup.content_change_allowed?
  end
  
  def has_all_roles?
    author_filled = false
    copyright_filled = false
    
    question_collaborators.each do |qc|
      author_filled ||= qc.is_author
      copyright_filled ||= qc.is_copyright_holder
    end
    
    author_filled && copyright_filled
  end
  
  def has_license?
    nil != license_id
  end
  
  def superseded?
    !latest_published_same_number.nil? && 
    latest_published_same_number.updated_at > self.created_at
  end
  
  def is_latest?
    latest_published_same_number == self
  end
  
  def next_available_version
    latest_published_same_number.nil? ? 
      1 : latest_published_same_number.version + 1
  end

  def latest_published_same_number
    Question.latest_published(self.number)
  end
  
  def is_draft_in_multipart?
    !is_published? && !multipart_questions.empty?
  end
  
  def is_multipart?
    false
  end
  
  def modified_at
    updated_at
  end
  
  def content_summary_string
    raise AbstractMethodCalled
  end
  
  def has_role?(user, role)
    qc = question_collaborators.select{|qc| qc.user_id == user.id}.first    
    qc.nil? ? false : qc.has_role?(role)
  end
  
  def is_collaborator?(user)
    question_collaborators.any?{|qc| qc.user_id == user.id}
  end
  
  def has_role_permission_as_deputy?(user, role)
    # TODO this is probably fairly costly and only applies to a small number
    # of users; so implement a counter_cache of num deputizers and check that
    # before doing this; also User.is_deputy_for? could benefit from what we 
    # do here
    user.deputizers.any? do |deputizer|
      has_role?(deputizer, role)
    end
  end
  
  def has_role_permission?(user, role)
    !user.is_anonymous? && (has_role?(user, role) || has_role_permission_as_deputy?(user, role))
  end

  def question_role_requests
    QuestionRoleRequest.for_question(self)
  end
  
  # Saves the question (for the first time), assigns roles to the given user,
  # and puts the question in the user's default list.  Throws exceptions
  # on errors.
  def create!(user, options ={})
    options[:set_initial_roles] = true if options[:set_initial_roles].nil?
    options[:list] = List.default_for_user!(user) if options[:list].nil?

    Question.transaction do
      self.save!
      self.set_initial_question_roles(user) if options[:set_initial_roles]
      options[:list].add_question!(self)
      QuestionDerivation.create(
        :source_question_id => options[:source_question].id,
        :deriver_id => options[:deriver_id],
        :derived_question_id => self.id) if (options[:source_question] &&
                                             options[:deriver_id])
    end
  end
  
  def new_derivation!(user, list = nil)
    return if !is_published?
    derived_question = self.content_copy
    
    Question.transaction do
      derived_question.create!(user, :list => list)
      QuestionDerivation.create(:source_question_id => self.id, 
                                :derived_question_id => derived_question.id,
                                :deriver_id => user.id)
    end
    
    derived_question
  end
  
  def new_version!(user, list = nil)
    new_version = self.content_copy
    new_version.number = self.number
    new_version.version = nil
    
    new_version.create!(user, {:list => list, :set_initial_roles => false})
    QuestionCollaborator.copy_roles(self, new_version)
    new_version
  end
  
  # Makes a new question that has a copy of the content in this question
  def content_copy
    raise AbstractMethodCalled
  end

  # Sets common question properties, given a copied question object
  def init_copy(kopy)
    kopy.license_id = self.license_id
    self.attachable_assets.each {|aa| kopy.attachable_assets.push(aa.content_copy) }
    kopy.tag_list = self.tag_list
    kopy.logic = self.logic.content_copy if !self.logic.nil?
    kopy
  end
  
  def is_derivation?
    !question_source.nil?
  end
  
  def has_earlier_versions?
    0 != version && !version.nil?
  end
  
  def get_ancestor_question
    has_earlier_versions? ? prior_version : (is_derivation? ? source_question : nil)
  end

  def can_be_joined_by?(user)
    !has_role?(user, :is_listed)
  end
  
  def self.search(type, location, part, text, user, exclude_type = '')
    # This should the most efficient way to do the search (I hope)
    # It does not use tagged_with and instead searches the database directly
    # I'm allowing partial tag searches for now (e.g. 'PEN' will match 2011 SPEN Sprint)
    # If this is not desirable, replace tags.name =~ query with tags.name == text
    # An ordering other than by id could also be used without any other modifications

    case location
    when 'Published Questions'
      wscope = published_questions
    when 'My Drafts'
      wscope = draft_questions
    when 'My Lists'
      wscope = user_list_questions(user)
    else #All Places
      wscope = Question
    end

    type_query = typify(type)
    wtscope = wscope.includes{question_setup}.where{question_type =~ type_query}

    if !exclude_type.blank?
      exclude_type_query = typify(exclude_type)
      wtscope = wtscope.where{question_type !~ exclude_type_query}
    end

    latest_only = true
    if !text.blank?
      case part
      when 'ID/Number'
        # Search by question ID or number (more relaxed than to_param)
        if (text =~ /^\s?(\d+)\s?$/) # Format: (id or number)
          id_query = $1
          num_query = $1
          q = wtscope.where{(id == id_query) | (number == num_query)}
        elsif (text =~ /^\s?d\.?\s?(\d+)\s?$/) # Format: d(id)
          id_query = $1
          q = wtscope.where{id == id_query}
          latest_only = false
        elsif (text =~ /^\s?q\.?\s?(\d+)(,?\s?v\.?\s?(\d+))?\s?$/)
          # Format: q(number) or q(number)v(version)
          num_query = $1
          if $2.nil?
            q = wtscope.where{number == num_query}
          elsif !$3.nil?
            ver_query = $3
            q = wtscope.where{(number == num_query) & (version == ver_query)}
            latest_only = false
          else # Invalid version
            return Question.none # Empty
          end
        else # Invalid ID/Number
          return Question.none # Empty
        end
      when 'Author/Copyright Holder'
        # Search by author (or copyright holder)
        q = wtscope.joins{question_collaborators.user}
        text.gsub(",", "").split.each do |t|
          query = t.blank? ? '%' : '%' + t + '%'
          q = q.where{(question_collaborators.user.first_name =~ query) |\
                      (question_collaborators.user.last_name =~ query)}
        end
      when 'Tags'
        # Search by tags
        q = wtscope.joins{taggings.tag}
        text.split(",").each do |t|
          query = t.blank? ? '%' : '%' + t + '%'
          q = q.where{tags.name =~ query}
        end
      else # Content
        query = '%' + text + '%'
        q = wtscope.where{(content =~ query) | (question_setups.content =~ query)}
      end
    else
      q = wtscope
    end
    
    # Remove (in SQL) questions the user can't read
    q = q.which_can_be_read_by(user)

    # Remove duplicates and allow the use of max()
    q = q.group{questions.id}

    if latest_only # Remove old published versions
      q = q.joins{questions_same_number}\
           .having{(version == nil) | (version == max(questions_same_number.version))}
    end
    q.order{number}
  end

  def roleless_collaborators
    question_collaborators.where{(is_author == false) & (is_copyright_holder == false)}
  end

  def valid_solutions_visible_for(user)
    s = solutions.visible_for(user)
    return s if changes_solution
    previous_published_questions = Question.published_with_number(number)
    previous_published_questions = previous_published_questions.where{version < my{version}} \
                                     if is_published?
    previous_published_questions.each do |pq|
      s |= pq.solutions.visible_for(user)
      break if pq.changes_solution
    end
    s
  end
  
  def base_class
    Question
  end

  def list
    raise IllegalState if is_published?
    list_questions.first.list
  end
  
  # In some cases, there could be some outstanding role requests on this question
  # but no role holders left to approve/reject them.  This method is a utility for
  # automatically granting all of those roles.
  def grant_all_requests_if_no_role_holders_left!
    if question_collaborators.none?{|qc| qc.has_role?(:any)}
      question_collaborators.each do |qc|
        qc.question_role_requests.each{|qrr| qrr.grant!}
      end
    end
  end
  
  # Visitor pattern.  The variator visits parts of the question (setup, 
  # subparts, etc) and helps build up the info for this specific variation.
  def variate!(variator)
    begin
      question_setup.variate!(variator) if question_setup
      variator.run(logic)
      @variated_content_html = variator.fill_in_variables(content_html)
    rescue Bullring::JSError => e
      logger.debug {"When variating question #{self.to_param} with seed #{variator.seed}, encountered a javascript error: " + e.inspect}
      self.errors.add(:base, "A logic error was encountered: #{e.message}")
    rescue BadFormatStringError => e
      self.errors.add(:base, "There is a malformed formatting string in this question: #{e.message}")
    end
  end
  
  #############################################################################
  # Access control methods
  #############################################################################

  def get_lock!(user)
    # This method checks that the user can get the lock and, if so, gets it and returns true.
    # Othewise, returns false.
    return true if @@lock_timeout <= 0
    # Transaction to make testing and setting the lock atomic
    self.with_lock do
      return already_locked_error if (self.is_locked? && !self.has_lock?(user))
      self.locked_by = user.id
      self.locked_at = Time.now
      self.save!
    end
  end

  def check_and_unlock!(user)
    # This method checks that the user has the lock and, if so, releases it and returns true.
    # Othewise, returns false.
    return true if @@lock_timeout <= 0
    # Transaction to make releasing the lock atomic
    self.with_lock do
      return not_locked_error if !self.is_locked?
      return already_locked_error if (self.is_locked? && !self.has_lock?(user))
      self.locked_by = -1
      self.save!
    end
  end

  def is_locked?
    locked_by && locked_by > 0 && locked_at && Time.current < (locked_at + @@lock_timeout)
  end

  def has_lock?(user)
    # This method's return value is only valid if is_locked? == true
    locked_by == user.id
  end

  def can_be_read_by?(user)
    is_published? || 
    ( !user.is_anonymous? && 
      (is_list_member?(user) || has_role_permission?(user, :any)) )
  end
    
  def can_be_created_by?(user)
    !user.is_anonymous?
  end
  
  def can_be_updated_by?(user)
    !is_published? && !user.is_anonymous? && 
    (is_list_member?(user) || has_role_permission?(user, :any))
  end
  
  def can_be_destroyed_by?(user)
    !is_published? && !user.is_anonymous? && 
    (is_list_member?(user) || has_role_permission?(user, :any))
  end
  
  def can_be_published_by?(user)
    !is_published? && !user.is_anonymous? && has_role_permission?(user, :any)
  end
  
  def can_be_new_versioned_by?(user)
    is_published? && is_latest? &&
    !user.is_anonymous? && has_role_permission?(user, :any)
  end
  
  def can_be_derived_by?(user)
    is_published? && !user.is_anonymous?
  end
  
  def can_be_tagged_by?(user)
    can_be_updated_by?(user) || has_role_permission?(user, :any)
  end
  
  # Special access method for role requests on this collaborator
  # defined here b/c called from different places
  def role_requests_can_be_created_by?(user)
    user.can_update?(self)
  end

  def is_list_member?(user)
    list_questions.each { |wp| return true if wp.list.is_member?(user) }
    false
  end
  
#############################################################################
protected
#############################################################################
    
  # Only assign a question number if the current number is nil.  When a new version
  # of an existing question is made, the number will already be set to the correct
  # value before this method is called.
  def assign_number
    self.number ||= (Question.maximum('number') || 1) + 1
  end
  
  def not_published
    return if (version_was.nil?)
    errors.add(:base, "Changes cannot be made to a published question.#{self.changes}")
    false
  end

  def clear_empty_logic
    if !logic.nil? && logic.empty?
      logic.destroy 
      self.logic = nil
    end
  end

  def set_default_license!
    self.license = License.default
  end

  def destroy_childless_question_setup
    if !question_setup.blank?
      question_setup.destroy_if_unattached
    end
  end

  def already_locked_error
    lock_minutes = ((locked_at + @@lock_timeout - Time.now)/60).ceil
    errors.add(:base, "Draft " + to_param + " (q. " + number.to_s +
                      ") is currently locked by " +
                      User.find(locked_by).full_name + " for at least " +
                      lock_minutes.to_s +
                      " more " + (lock_minutes == 1 ? "minute" : "minutes") + ".")
    false
  end

  def not_locked_error
    errors.add(:base, "You do not currently have the lock on draft " + to_param +
                      " (q. " + number.to_s + "). This can be caused by long" +
                      " periods of inactivity. Please try again.")
    false
  end

  def self.typify(text)
    (text.blank? || text == 'All Questions') ? '%' : text.gsub(' ', '').classify
  end
  
  # Template method overridable by a child class for child-specific behavior
  def run_prepublish_hooks(user); end

end
