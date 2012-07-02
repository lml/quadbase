# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class SimpleQuestionTest < ActiveSupport::TestCase
  
  fixtures
  self.use_transactional_fixtures = true
  
  test "all nil values is ok" do
    assert SimpleQuestion.new.valid?
  end
  
  test "empty content is ok but can't publish" do
    sq = FactoryGirl.build(:simple_question, :content => '')
    assert !sq.invalid?
    assert !sq.publish!(FactoryGirl.create(:user))
  end
  
  test "has at least one right answer" do
    sq = FactoryGirl.create(:simple_question_with_choices)
    assert sq.valid?
    
    sq.answer_choices.each{|ac| ac.credit = 0}
    assert sq.invalid?
    
    assert_equal sq.answer_choices.first.question, sq
  end
  
  test "doesn't have just one MC answer" do
    sq = make_simple_question(:answer_credits => [1])
    assert sq.invalid?
  end
  
  test "cannot delete published question" do
    sq = make_simple_question({:answer_credits => [0,1,0,0], 
                               :published => true,
                               :method => :create})
    
    assert !sq.destroy
    assert !sq.errors.empty?
  end
  
  test "cannot edit published question" do
    sq = make_simple_question({:answer_credits => [0,1,0,0], 
                               :published => true,
                               :method => :create})
    
    assert !sq.update_attributes(:content => "This shouldn't get saved")
    assert !sq.errors.empty?
    assert_raise(ActiveRecord::RecordInvalid) {sq.save!}
    
    sq.reload
    
    sq.answer_choices = []
  end
  
  test "deleting unpub question deletes direct associations" do 
    sq = make_simple_question(:answer_credits => [1,0], :method => :create)
    sq.answer_choices.each { |ac| ac.save! }
    first_id = sq.answer_choices.first.id
    last_id = sq.answer_choices.last.id
    sq.destroy
    
    assert_raise(ActiveRecord::RecordNotFound) { AnswerChoice.find(first_id) }
    assert_raise(ActiveRecord::RecordNotFound) { AnswerChoice.find(last_id) }    
  end
  
  test "content copy" do
    sq0 = make_simple_question()
    sq1 = sq0.content_copy()
    assert_not_equal sq0, sq1
    assert_equal sq0.content, sq1.content
    for i in (0...sq0.answer_choices.length)
        a0 = sq0.answer_choices[i]
        a1 = sq1.answer_choices[i]
        assert_not_equal a0, a1
        assert_equal a0.content, a1.content
        assert_equal a0.credit, a1.credit
    end
    assert_not_equal sq0.question_setup, sq1.question_setup
    assert_equal sq0.question_setup.content, sq1.question_setup.content
    assert_equal sq0.license_id, sq1.license_id
  end
  
  test "basic logic" do
    ContentParseAndCache.enable_test_parser = true
    ll = FactoryGirl.create(:logic, :code => 'x = 4;', :variables => 'x')
    sq = FactoryGirl.build(:simple_question, :content => 'The magic variable is =x=')
    sq.logic = ll
    sq.save
    ll.save
    qv = QuestionVariator.new(2e9)
    sq.variate!(qv)
    ContentParseAndCache.enable_test_parser = false
  end
  
  # TODO implement the following tests
  # 
  # test "publish with same setup reuses setup" do
  # end
end
