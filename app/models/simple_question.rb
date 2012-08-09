# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class SimpleQuestion < Question
  include ContentParseAndCache
  
  has_many :answer_choices, :dependent => :destroy, :foreign_key => :question_id
  
  validate :at_least_one_right_answer
  validate :not_just_one_answer
  
  accepts_nested_attributes_for :answer_choices, :allow_destroy => true

  attr_accessible :answer_choices_attributes
  
  def modified_at
    times = [updated_at]
    times << answer_choices.collect{|ac| ac.updated_at}
    times << question_setup.updated_at if !question_setup.nil?
    times.flatten.max
  end
  
  def content_summary_string
    string = ""
    string << question_setup.content[0..15] << " ... " \
      if (!question_setup.nil? && !question_setup.content.blank?)
    string << content if !content.blank?
  end
  
  def content_copy
    kopy = SimpleQuestion.create
    init_copy(kopy)
    old_setup = kopy.question_setup
    kopy.question_setup = self.question_setup.content_copy if !self.question_setup_id.nil?
    old_setup.destroy_if_unattached
    self.answer_choices.each {|ac| kopy.answer_choices.push(ac.content_copy) }
    kopy.content = self.content
    kopy
  end

  def add_other_prepublish_errors
    self.errors.add(:base,'Content must not be empty.') if content.blank?
    answer_choices.each do |ac|
      self.errors.add(:answer_choices, 'Content must not be empty.') if ac.content.blank?
    end
  end
  
  def variate!(variator)
    super(variator)
    answer_choices.each {|ac| ac.variate!(variator)}
  end
  
protected
  
  def at_least_one_right_answer
    return if answer_choices.empty?
    
    answer_choices.each do |ac|
      return if ac.credit == 1
    end
    
    errors.add(:answer_choices, "must contain at least one right answer.")
    false
  end
  
  def not_just_one_answer
    return if answer_choices.size != 1
    errors.add(:base, "A question with multiple choice answers must have at least two answers.")
    false
  end

  def run_prepublish_hooks(user)
    reuse_ancestor_setup_if_equal  # TODO bump this up into question?
  end
  
  # If this question has a ancestor (it is a derived question or a new version), 
  # check to see if the setup is the same as in the ancestor question.  If so, 
  # set this guy's setup to point to the ancestor one (so we can hang many 
  # questions off of the same source)
  def reuse_ancestor_setup_if_equal
    ancestor = get_ancestor_question
    
    return if ancestor.nil?
    return if ancestor.question_setup_id.nil? || self.question_setup_id.nil?    
    return if ancestor.question_setup != self.question_setup
    
    self.question_setup_id = ancestor.question_setup_id 
  end
  
end
