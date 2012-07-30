# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class MatchingQuestion < Question
  include ContentParseAndCache
  
  has_many :match_items, :dependent => :destroy, :foreign_key => :question_id

  accepts_nested_attributes_for :match_items, :allow_destroy => true

  attr_accessible :match_items_attributes

  def content_summary_string
    string = ""
    string << question_setup.content[0..15] << " ... " \
      if (!question_setup.nil? && !question_setup.content.blank?)
    string << content if !content.blank?
  end
  
  def content_copy
    kopy = MatchingQuestion.create
    init_copy(kopy)
    old_setup = kopy.question_setup
    kopy.question_setup = self.question_setup.content_copy if !self.question_setup_id.nil?
    old_setup.destroy_if_unattached
    self.match_items.where{(right_column == false) | (match_id == nil)} \
                    .each {|m| kopy.match_items.push(m.content_copy) }
    kopy.content = self.content
    kopy
  end
  
  def add_other_prepublish_errors
    self.errors.add(:base,'Content must not be empty.') if content.blank?
    match_items.each do |m|
      self.errors.add(:match_items, 'Content must not be empty.') if m.content.blank?
    end
  end
end
