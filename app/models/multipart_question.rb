# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class MultipartQuestion < Question
  include ContentParseAndCache

  has_many :child_question_parts,
           :class_name => "QuestionPart",
           :foreign_key => "multipart_question_id",
           :order => :order,
           :dependent => :destroy
  has_many :child_questions,
           :through => :child_question_parts
  
  def add_other_prepublish_errors
    self.errors.add(:base,'A multi-part question must contain at least one part.') \
      if child_question_parts.empty?
        
    child_question_parts.each do |part|
      # Only unpublished children will be published, so it is only them
      # that we want to check for errors.
      child = part.child_question
      if !child.is_published? && !child.ready_to_be_published?
        self.errors.add(:base, "Part #{part.order}: " + 
                        child.errors[:base].join("; ") + "")
      end
    end
  end
  
  def run_prepublish_hooks(user)
    child_questions.each do |child|
      child.publish!(user) if !child.is_published?
    end
  end
  
  def content_summary_string
    string = ""
    string << question_setup.content[0..15] << " ... " \
      if (!question_setup.nil? && !question_setup.content.blank?)
    string << "[" << child_question_parts.size.to_s << " questions]"
  end
  
  def content_copy
    kopy = MultipartQuestion.create
    init_copy(kopy)
    self.child_question_parts.each do |part| 
      new_part = part.content_copy
      new_part.multipart_question = kopy
      kopy.child_question_parts.push(new_part)
    end
    kopy
  end
  
  def add_parts(questions)
    questions = Array(questions)
    
    self.errors.add(:base, "Cannot add parts to a published question.") if is_published?
    
    # There can be no duplicate incoming questions
    
    if !questions.uniq!.nil?
      self.errors.add(:base, "Questions cannot be added more than once to " + 
                             "a multipart question.")
    end
    
    # The incoming questions can't already be in the multipart
    
    preexisting_questions = child_questions & questions

    if !preexisting_questions.empty?
      id_string = preexisting_questions.collect{|q| q.to_param}.join(', ')
      self.errors.add(:base, "Question(s) #{id_string} are already a part " + 
                             "of the multipart question.")
    end

    # Do not allow multiparts to be added to other multiparts

    questions.each do |question|
      if question.question_type == "MultipartQuestion"
        self.errors.add(:base, "Question #{question.to_param} is a multipart question" +
                               " and cannot be part of another multipart question.")
      end
    end
    
    # All of the incoming questions must have the same introduction.  The one
    # exception is questions that don't have to have an intro, in which case
    # it will be changed (draft) or left unmodified (published)

    setup_ids = questions.collect do |q|
      setup = q.question_setup
      setup.nil? ? nil : setup.content.blank? ? nil : setup.id
    end

    setup_ids.reject!{|id| id.nil?}
    uniq_non_nil_setup_ids = setup_ids.uniq

    if uniq_non_nil_setup_ids.size > 1
      self.errors.add(:base, "The selected questions have different introductions.")
    else

      # If this question's intro is blank and it is legal for it to be changed,
      # the intro will change to match that of the incoming questions (assuming
      # they have intros).  If this question's intro doesn't meet these conditions
      # (i.e. it cannot be changed), then the intro from the incoming questions 
      # must be identical to this question's existing intro.
    
      single_setup_id = uniq_non_nil_setup_ids.size == 1 ? 
                        uniq_non_nil_setup_ids.first : self.question_setup_id

      setup_can_change_to_incoming_setup = \
        self.question_setup.content.blank? && setup_is_changeable?
      
      single_different_incoming_setup = self.question_setup_id != single_setup_id
    
      if single_different_incoming_setup && !setup_can_change_to_incoming_setup
        self.errors.add(:base, "The selected questions have a different introduction than " +
                               "that of the multipart question.")
      end
    end
    
    # Bail out before changing the question if there are errors
    
    return false if !self.errors.empty?
    
    # Below, do the work to add the questions
    #
    # Note that we want to wrap all of these actions in a transaction because they
    # should happen together or not at all.  We expect that most of the exceptions
    # have been precluded based on the checks above.  If however, some make it thru
    # they will cause the transaction to fail and be passed up to log reporting
    # mechanisms.
    
    Question.transaction do
      # As discussed above, if this question's intro can be changed and there is
      # a single incoming setup that differs from the existing multipart intro, go
      # ahead and change it in the multipart and in any children.

      single_setup = QuestionSetup.find(single_setup_id)
      
      if single_different_incoming_setup
        set_question_setup!(single_setup)
      end

      # Set all question setups to the single setup, unless published

      questions.each do |question|
        if !question.is_published?
          old_question_setup = question.question_setup
          question.question_setup = single_setup
          question.save!
          old_question_setup.destroy_if_unattached
        end
      end

      # Finally, add the incoming questions
      
      child_questions << questions
    end
  end
  
  def create!(user, options ={})
    child_questions.each do |child|
      child.create!(user, options) if !child.is_published?
    end
    
    super(user, options)
  end
  
  
  def last_part
    child_question_parts.last
  end
  
  def remove_part(question)
    # If a published question was added, this q's setup will be set to that
    # published part's setup.  If that published part is removed, we should make it
    # so that the multipart setup is editable again.  This would mean copying the 
    # content to a new setup and changing the setup_ids in the relevant questions.
    child_questions.delete(question)
    published_uniq_setup_ids = child_questions.select{|q| q.is_published? && !q.question_setup.nil? &&
                                                          !q.question_setup.content.blank?}
                                              .collect{|q| q.question_setup_id}.uniq

    if published_uniq_setup_ids.size == 0
      new_setup = question_setup.content_copy
      new_setup.save!
      set_question_setup!(new_setup)
    end
  end
  
  def is_multipart?
    true
  end

protected

  def set_question_setup!(qs)
    old_question_setup = self.question_setup
          
    # Assigning objects instead of IDs keeps the multipart object up to date
    self.question_setup = qs
    self.save!
        
    self.child_questions.each do |child_question|
      if !child_question.is_published?
        child_question.question_setup = qs
        child_question.save!
      end
    end
          
    # Clean up orphaned intros
    old_question_setup.destroy_if_unattached
  end
  
end
