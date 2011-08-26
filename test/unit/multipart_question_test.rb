# Copyright (c) 2011 Rice University.  All rights reserved.

require 'test_helper'

class MultipartQuestionTest < ActiveSupport::TestCase

  test "create" do
    mpq = Factory.create(:multipart_question)
    assert_not_nil mpq.question_setup
  end

  test "child_questions" do
    qp = Factory.create(:question_part)
    assert !qp.multipart_question.child_questions.empty?, 'a'
    
    mpq = Factory.create(:multipart_question)
    sq = Factory.create(:simple_question, :question_setup_id => mpq.question_setup_id)

    assert mpq.add_parts(sq)
    assert mpq.errors.empty?
    assert !mpq.child_questions.empty?
  end

  test "add_parts" do
    mpq = Factory.create(:multipart_question)
    
    assert_equal 0, mpq.child_question_parts.size, "a"
    assert_equal 0, mpq.child_questions.size, "b"
    
    sq = Factory.create(:simple_question, :question_setup_id => mpq.question_setup_id)
    
    mpq.add_parts(sq)
    
    assert_equal 1, mpq.child_question_parts.size, "c"
    assert_equal 1, mpq.child_questions.size, "d"
    
    assert_equal mpq.child_questions.first, sq, "e"
    assert_equal 1, mpq.child_question_parts.first.order
    
    sq2 = Factory.create(:simple_question, :question_setup_id => mpq.question_setup_id)
    
    mpq.add_parts(sq2)
    
    assert_equal 2, mpq.child_question_parts.last.order
  end
  
  test "can't add parts to a published question" do
    mpq = make_multipart_question(:publish => true)
    sq = Factory.build(:simple_question, :question_setup_id => mpq.question_setup_id)

    assert !mpq.add_parts(sq)    
    assert !mpq.errors.empty?
  end
  
  test "can't add duplicate questions at once" do
    mpq = Factory.create(:multipart_question)
    sq = Factory.create(:simple_question, :question_setup_id => mpq.question_setup_id)

    assert !mpq.add_parts([sq, sq])
    assert !mpq.errors.empty?
  end
  
  test "can't add draft w/o setup" do
    mpq = Factory.create(:multipart_question)
    sq = Factory.create(:simple_question)

    assert !mpq.add_parts(sq)
    assert !mpq.errors.empty?    
  end

  test "can add a published part without an intro" do
    mpq = Factory.create(:multipart_question)
    sq1 = Factory.create(:simple_question, :question_setup_id => mpq.question_setup_id)
    sq2 = make_simple_question(:published => true, :method => :create, :no_setup => true)

    assert mpq.add_parts([sq1, sq2])
    assert mpq.errors.empty?    
  end
  
  test "incoming parts must have the same intro" do
    mpq = Factory.create(:multipart_question)
    sq1 = Factory.create(:simple_question, :question_setup_id => mpq.question_setup_id)
    sq2 = make_simple_question(:method => :create)    
    
    assert !mpq.add_parts([sq1, sq2])
    assert !mpq.errors.empty?
  end
  
  test "incoming parts must have the same intro as the multipart" do
    mpq = Factory.create(:multipart_question)
    sq1 = Factory.create(:simple_question)

    assert !mpq.add_parts(sq1)
    assert !mpq.errors.empty?
  end
  
  test "multipart without an intro takes on incoming intro" do
    mpq = Factory.create(:multipart_question, :question_setup => Factory.create(:question_setup, :content => " "))
    sq = Factory.create(:simple_question)
    
    old_mpq_setup_id = mpq.question_setup_id
    assert_nothing_raised(ActiveRecord::RecordNotFound) { QuestionSetup.find(old_mpq_setup_id)}
    
    mpq.add_parts(sq)
    assert_equal mpq.question_setup_id, sq.question_setup_id
    
    # test cleanup of orphaned question setup
    assert_raise(ActiveRecord::RecordNotFound) { QuestionSetup.find(old_mpq_setup_id)}
  end
  
  test "add new part" do
    mpq = Factory.create(:multipart_question)
  end
  
  test "cannot add part twice" do
    mpq = Factory.create(:multipart_question)
    sq = Factory.create(:simple_question, :question_setup_id => mpq.question_setup_id)
    
    mpq.add_parts(sq)
    assert !mpq.add_parts(sq), 'b'
    assert !mpq.errors.empty?, 'c'
  end
  
  test "can modify setup in a part" do
    # This is allowed b/c the question setup doesn't belong to any published q's.
    mpq = Factory.create(:multipart_question)
    sq = Factory.create(:simple_question, :question_setup_id => mpq.question_setup_id)

    sq.update_attributes(:question_setup_attributes => {:content => "test"})
    assert sq.valid?
  end
  
  test "normal publish" do
    mpq = Factory.create(:multipart_question)
    sq1 = Factory.create(:simple_question, :question_setup_id => mpq.question_setup_id)
    sq2 = Factory.create(:simple_question, :question_setup_id => mpq.question_setup_id)
    sq3 = make_simple_question(:no_setup => true, :published => true)
    mpq.add_parts([sq1, sq2, sq3])
    
    user = Factory.create(:user)
    [mpq, sq1, sq2].each{|q| q.set_initial_question_roles(user)}
    
    assert mpq.ready_to_be_published?

    assert !mpq.is_published?
    assert !sq1.is_published?
    assert !sq2.is_published?
    
    assert_nothing_raised{ mpq.publish!(user) }
    assert mpq.errors.empty?    
    
    assert mpq.is_published?
    assert sq1.is_published?
    assert sq2.is_published?
  end
  
  test "bad publish" do
    mpq = Factory.create(:multipart_question)
    sq1 = Factory.create(:simple_question, :question_setup_id => mpq.question_setup_id)
    sq2 = Factory.create(:simple_question, :question_setup_id => mpq.question_setup_id)
    sq3 = make_simple_question(:no_setup => true, :published => true)
    mpq.add_parts([sq1, sq2, sq3])

    user = Factory.create(:user)
    [mpq, sq1].each{|q| q.set_initial_question_roles(user)} # leave sq2 out

    assert !mpq.ready_to_be_published?

    assert mpq.publish!(user).nil?
    assert !mpq.errors.empty?

    assert !mpq.is_published?
    assert !sq1.is_published?
    assert !sq2.is_published?
  end
  
  test "content copy" do
    mpq = Factory.create(:multipart_question)
    sq1 = Factory.create(:simple_question, :question_setup_id => mpq.question_setup_id)
    sq2 = Factory.create(:simple_question, :question_setup_id => mpq.question_setup_id)
    sq3 = make_simple_question(:no_setup => true, :published => true)
    mpq.add_parts([sq1, sq2, sq3])
    
    pre_copy_time = Time.now
    
    kopy = mpq.content_copy
    
    assert_equal kopy.question_setup.content, mpq.question_setup.content
    assert_equal kopy.child_question_parts.size, mpq.child_question_parts.size
    
    (0..kopy.child_question_parts.size-1).each do |ii|
      assert_equal kopy.child_question_parts[ii].order, mpq.child_question_parts[ii].order
      assert_equal kopy.child_question_parts[ii].child_question, mpq.child_question_parts[ii].child_question
    end
    
    kopy.save!
    
    # Make sure original didnt' change
    assert mpq.child_question_parts[0].updated_at < pre_copy_time
  end
  
  # TODO
  #
  # test "setup_is_changeable?"
  # end
  # 
  # test "last_part"
  # end
  # 
  # test "remove_part"
  # end
end
