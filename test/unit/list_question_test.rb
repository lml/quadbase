# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class ListQuestionTest < ActiveSupport::TestCase

  fixtures
  self.use_transactional_fixtures = true

  test "drafts can only be in one list" do
    q = make_simple_question
    
    FactoryGirl.create(:list_question, :question => q)
    assert_raise(ActiveRecord::RecordInvalid) { 
      FactoryGirl.create(:list_question, :question => q)
    }
  end
  
  test "published questions can be in any lists" do
    q = make_simple_question(:published => true)
    
    FactoryGirl.create(:list_question, :question => q)
    assert_nothing_raised(ActiveRecord::RecordInvalid) { 
      FactoryGirl.create(:list_question, :question => q)
    }    
  end

  test "move!" do
    q = make_simple_question
    
    old_list = FactoryGirl.create(:list)
    new_list = FactoryGirl.create(:list)
            
    wq = FactoryGirl.create(:list_question, 
                        :question => q,
                        :list => old_list)
    
    wq.move!(new_list)    
    wq.reload
    
    assert_equal new_list, wq.list
  end
  
  test "move multipart" do
    mpq = FactoryGirl.create(:multipart_question)
    sq1 = FactoryGirl.create(:simple_question, :question_setup_id => mpq.question_setup_id)

    mpq.add_parts([sq1])
    
    old_list = FactoryGirl.create(:list)
    new_list = FactoryGirl.create(:list)
    
    mpq_pq = FactoryGirl.create(:list_question, 
                            :question => mpq,
                            :list => old_list)
    sq1_pq = FactoryGirl.create(:list_question, 
                            :question => sq1,
                            :list => old_list)

    mpq_pq.move!(new_list)
    
    assert_equal new_list, mpq_pq.list, "a"
    assert_equal new_list, sq1_pq.reload.list, "b"
  end
  
  test "copy!" do
    u = FactoryGirl.create(:user)
    q = make_simple_question
    q.content = 'Unpublished'
    q.save!
    
    old_list = FactoryGirl.create(:list)
    new_list = FactoryGirl.create(:list)
            
    wq = FactoryGirl.create(:list_question, 
                        :question => q,
                        :list => old_list)
    
    
    assert_difference('new_list.questions.count') do
      qc = wq.copy!(new_list, u).question
      assert_equal q.content, qc.content
    end

    pq = make_simple_question(:method => :create)
    pq.content = 'Published'
    pq.save!
    pq.publish!(u)

    pwq = FactoryGirl.create(:list_question, 
                         :question => pq,
                         :list => old_list)

    assert_difference('pq.derived_questions.count') do
      assert_difference('new_list.questions.count') do
        qc = pwq.copy!(new_list, u).question
        assert_equal pq.content, qc.content
      end
    end

    q2 = pq.new_derivation!(u, old_list)
    q2.content = 'Published derivation'
    q2.save!

    wq2 = q2.list_questions.first

    assert_difference('pq.derived_questions.count') do
      assert_difference('new_list.questions.count') do
        qc = wq2.copy!(new_list, u).question
        assert_equal q2.content, qc.content
      end
    end

    q3 = pq.new_version!(u, old_list)
    q3.content = 'Published v2'
    q3.save!

    wq3 = q3.list_questions.first

    assert_difference('pq.derived_questions.count') do
      assert_difference('new_list.questions.count') do
        qc = wq3.copy!(new_list, u).question
        assert_equal q3.content, qc.content
      end
    end

  end
  
end
