# Copyright (c) 2011 Rice University.  All rights reserved.

class AnswerChoice < ActiveRecord::Base
  include ContentParseAndCache
  include AssetMethods

  belongs_to :question
  
  validates_presence_of :content, :credit
  
  validates_numericality_of :credit,
                            :greater_than_or_equal_to => 0,
                            :less_than_or_equal_to => 1,
                            :allow_nil => true
  validate :parse_succeeds

  before_save :cache_html
  before_destroy :question_not_published
  validate :question_not_published, :on => :update

  attr_accessible :content, :credit
  
  def content_copy
    AnswerChoice.new(:content => content, :credit => credit)
  end
  
  def get_attachable
    question
  end
  
  protected
  
  def question_not_published
    return if !question.is_published?
    errors.add(:base, "Cannot modify a question answer after the question is published.")
    false
  end                          
end
