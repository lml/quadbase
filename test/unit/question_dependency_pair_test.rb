# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class QuestionDependencyPairTest < ActiveSupport::TestCase

  test "basic" do
    qdp = FactoryGirl.build(:question_dependency_pair)
    assert_not_nil qdp.independent_question
    assert_not_nil qdp.dependent_question
    
    assert qdp.is_requirement?
    assert !qdp.is_support?
  end
  
  test "dependent can't be published" do
    sq_pub = make_simple_question({:published => true, :method => :create})
    sq_unpub = make_simple_question({:published => false, :method => :create})
    
    assert_nothing_raised{
      FactoryGirl.create(:question_dependency_pair,
                     :independent_question => sq_pub,                    
                     :dependent_question => sq_unpub)}

    assert_raise(ActiveRecord::RecordInvalid) {
      FactoryGirl.create(:question_dependency_pair,
                     :independent_question => sq_unpub, 
                     :dependent_question => sq_pub)
    }                                
  end
  
  test "no duplicate pairs" do
    qdp = FactoryGirl.create(:question_dependency_pair, :kind => "requirement")
    
    assert_raise(ActiveRecord::RecordInvalid) {
      FactoryGirl.create(:question_dependency_pair,
                     :independent_question => qdp.independent_question, 
                     :dependent_question => qdp.dependent_question,
                     :kind => "requirement")
    }
    
    assert_nothing_raised {
      FactoryGirl.create(:question_dependency_pair,
                     :independent_question => qdp.independent_question, 
                     :dependent_question => qdp.dependent_question,
                     :kind => "support")
    }
  end
  
  test "is_requirement" do
    qdp = FactoryGirl.create(:question_dependency_pair, :kind => "requirement")
    assert qdp.is_requirement?
  end
  
  test "is_support" do
    qdp = FactoryGirl.create(:question_dependency_pair, :kind => "support")
    assert qdp.is_support?
  end
end
