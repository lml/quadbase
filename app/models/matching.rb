# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class Matching < ActiveRecord::Base

  belongs_to :question

  attr_accessible :content, :choice_id, :matched_id, :column, :updated_at
  validate :question_not_published
  validate :question_not_changed, :on => :update
  validates_presence_of :question
  
  attr_writer :variated_content_html
  
  def variated_content_html
    @variated_content_html || self.content_html
  end

  def content_copy
    Matching.new(:content => content, :choice_id => choice_id,
                 :matched_id => matched_id, :column => column)
  end
  
  def variate!(variator)
    @variated_content_html = variator.fill_in_variables(content_html)
  end
  
  def get_attachable
    question
  end

  protected

  def question_not_published
    return if !question.try(:is_published?)
    errors.add(:base, "Cannot modify a published question's matchings.")
    false
  end
  
  def question_not_changed
    return if !question_id_changed?
    errors.add(:base, "Cannot move a matching to another question.")
    false
  end
end
