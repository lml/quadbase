# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class ProjectQuestionTest < ActiveSupport::TestCase

  fixtures
  self.use_transactional_fixtures = true

  test "drafts can only be in one project" do
    q = make_simple_question
    
    Factory.create(:project_question, :question => q)
    assert_raise(ActiveRecord::RecordInvalid) { 
      Factory.create(:project_question, :question => q)
    }
  end
  
  test "published questions can be in any projects" do
    q = make_simple_question(:published => true)
    
    Factory.create(:project_question, :question => q)
    assert_nothing_raised(ActiveRecord::RecordInvalid) { 
      Factory.create(:project_question, :question => q)
    }    
  end

  test "move!" do
    q = make_simple_question
    
    old_project = Factory.create(:project)
    new_project = Factory.create(:project)
            
    wq = Factory.create(:project_question, 
                        :question => q,
                        :project => old_project)
    
    wq.move!(new_project)    
    wq.reload
    
    assert_equal new_project, wq.project
  end
  
  test "move multipart" do
    mpq = Factory.create(:multipart_question)
    sq1 = Factory.create(:simple_question, :question_setup_id => mpq.question_setup_id)

    mpq.add_parts([sq1])
    
    old_project = Factory.create(:project)
    new_project = Factory.create(:project)
    
    mpq_pq = Factory.create(:project_question, 
                            :question => mpq,
                            :project => old_project)
    sq1_pq = Factory.create(:project_question, 
                            :question => sq1,
                            :project => old_project)

    mpq_pq.move!(new_project)
    
    assert_equal new_project, mpq_pq.project, "a"
    assert_equal new_project, sq1_pq.reload.project, "b"
  end
  
  test "copy!" do
    u = Factory.create(:user)
    q = make_simple_question
    
    old_project = Factory.create(:project)
    new_project = Factory.create(:project)
            
    wq = Factory.create(:project_question, 
                        :question => q,
                        :project => old_project)
    
    
    assert_difference('new_project.questions.count') do
      wq.copy!(new_project, u)
    end
    
    pq = make_simple_question(:method => :create, :published => true)

    pwq = Factory.create(:project_question, 
                         :question => pq,
                         :project => old_project)

    assert_difference('pq.derived_questions.count') do
      pwq.copy!(new_project, u)
    end

    q2 = pq.new_derivation!(u, old_project)
    wq2 = q2.project_questions.first

    assert_difference('pq.derived_questions.count') do
      wq2.copy!(new_project, u)
    end

    q3 = pq.new_version!(u, old_project)
    wq3 = q3.project_questions.first

    assert_difference('pq.derived_questions.count') do
      wq3.copy!(new_project, u)
    end
  end
  
end
