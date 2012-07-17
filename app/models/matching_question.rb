# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class MatchingQuestion < Question
  include ContentParseAndCache
  
  belongs_to :question
  has_many :matchings, :dependent => :destroy, :foreign_key => :question_id


  accepts_nested_attributes_for :matchings, :allow_destroy => true

  attr_accessible :matchings_attributes

  def content_summary_string
    string = ""
    string << question_setup.content[0..15] << " ... " \
      if (!question_setup.nil? && !question_setup.content.blank?)
    string << content if !content.blank?
  end

end
