# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class AnswerChoice < ActiveRecord::Base
  include ContentParseAndCache
  include AssetMethods
  include VariatedContentHtml
  
  belongs_to :question
  validates_presence_of :content, :credit
  validate :parse_succeeds
  validates_numericality_of :credit,
                            :greater_than_or_equal_to => 0,
                            :less_than_or_equal_to => 1,
                            :allow_nil => true

  before_save :cache_html
  before_destroy :question_not_published
  validate :question_not_published, :on => :update

  attr_accessible :content, :credit, :updated_at
  
  def content_copy
    AnswerChoice.new(:content => content, :credit => credit)
  end
  
  def get_attachable
    question
  end
  
  def variate!(variator)
    @variated_content_html = variator.fill_in_variables(content_html)
  end


  protected

  def question_not_published
    return if !question.is_published?
    errors.add(:base, "Cannot modify a question answer after the question is published.")
    false
  end                          
end
