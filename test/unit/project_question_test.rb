# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class ProjectQuestionTest < ActiveSupport::TestCase

  fixtures
  self.use_transactional_fixtures = true

  test "drafts can only be in one project" do
    q = make_simple_question
    
    FactoryGirl.create(:project_question, :question => q)
    assert_raise(ActiveRecord::RecordInvalid) { 
      FactoryGirl.create(:project_question, :question => q)
    }
  end
  
  test "published questions can be in any projects" do
    q = make_simple_question(:published => true)
    
    FactoryGirl.create(:project_question, :question => q)
    assert_nothing_raised(ActiveRecord::RecordInvalid) { 
      FactoryGirl.create(:project_question, :question => q)
    }    
  end

  test "move!" do
    q = make_simple_question
    
    old_project = FactoryGirl.create(:project)
    new_project = FactoryGirl.create(:project)
            
    wq = FactoryGirl.create(:project_question, 
                        :question => q,
                        :project => old_project)
    
    wq.move!(new_project)    
    wq.reload
    
    assert_equal new_project, wq.project
  end
  
  test "move multipart" do
    mpq = FactoryGirl.create(:multipart_question)
    sq1 = FactoryGirl.create(:simple_question, :question_setup_id => mpq.question_setup_id)

    mpq.add_parts([sq1])
    
    old_project = FactoryGirl.create(:project)
    new_project = FactoryGirl.create(:project)
    
    mpq_pq = FactoryGirl.create(:project_question, 
                            :question => mpq,
                            :project => old_project)
    sq1_pq = FactoryGirl.create(:project_question, 
                            :question => sq1,
                            :project => old_project)

    mpq_pq.move!(new_project)
    
    assert_equal new_project, mpq_pq.project, "a"
    assert_equal new_project, sq1_pq.reload.project, "b"
  end
  
  test "copy!" do
    u = FactoryGirl.create(:user)
    q = make_simple_question
    q.content = 'Unpublished'
    q.save!
    
    old_project = FactoryGirl.create(:project)
    new_project = FactoryGirl.create(:project)
            
    wq = FactoryGirl.create(:project_question, 
                        :question => q,
                        :project => old_project)
    
    
    assert_difference('new_project.questions.count') do
      qc = wq.copy!(new_project, u).question
      assert_equal q.content, qc.content
    end

    pq = make_simple_question(:method => :create)
    pq.content = 'Published'
    pq.save!
    pq.publish!(u)

    pwq = FactoryGirl.create(:project_question, 
                         :question => pq,
                         :project => old_project)

    assert_difference('pq.derived_questions.count') do
      assert_difference('new_project.questions.count') do
        qc = pwq.copy!(new_project, u).question
        assert_equal pq.content, qc.content
      end
    end

    q2 = pq.new_derivation!(u, old_project)
    q2.content = 'Published derivation'
    q2.save!

    wq2 = q2.project_questions.first

    assert_difference('pq.derived_questions.count') do
      assert_difference('new_project.questions.count') do
        qc = wq2.copy!(new_project, u).question
        assert_equal q2.content, qc.content
      end
    end

    q3 = pq.new_version!(u, old_project)
    q3.content = 'Published v2'
    q3.save!

    wq3 = q3.project_questions.first

    assert_difference('pq.derived_questions.count') do
      assert_difference('new_project.questions.count') do
        qc = wq3.copy!(new_project, u).question
        assert_equal q3.content, qc.content
      end
    end

  end
  
end
