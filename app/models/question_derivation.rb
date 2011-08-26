# Copyright (c) 2011 Rice University.  All rights reserved.

class QuestionDerivation < ActiveRecord::Base
  belongs_to :source_question, :class_name => "Question"
  belongs_to :derived_question, :class_name => "Question"
  belongs_to :deriver, :class_name => "User"
  
  validates_presence_of :source_question_id, :derived_question_id, :deriver_id
  
  # A question ID should only fall in the derived id column once (because
  # one question cannot be derived from multiple sources)
  validates_uniqueness_of :derived_question_id

  attr_accessible :source_question_id, :derived_question_id, :deriver_id

end
