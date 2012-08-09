# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class MultipartQuestionTest < ActiveSupport::TestCase

  test "create" do
    mpq = FactoryGirl.create(:multipart_question)
    assert_not_nil mpq.question_setup
  end

  test "child_questions" do
    qp = FactoryGirl.create(:question_part)
    assert !qp.multipart_question.child_questions.empty?, 'a'
    
    mpq = FactoryGirl.create(:multipart_question)
    sq = FactoryGirl.create(:simple_question, :question_setup_id => mpq.question_setup_id)

    assert mpq.add_parts(sq)
    assert mpq.errors.empty?
    assert !mpq.child_questions.empty?
  end

  test "add_parts" do
    mpq = FactoryGirl.create(:multipart_question)
    
    assert_equal 0, mpq.child_question_parts.size, "a"
    assert_equal 0, mpq.child_questions.size, "b"
    
    sq = FactoryGirl.create(:simple_question, :question_setup_id => mpq.question_setup_id)
    
    mpq.add_parts(sq)
    
    assert_equal 1, mpq.child_question_parts.size, "c"
    assert_equal 1, mpq.child_questions.size, "d"
    
    assert_equal mpq.child_questions.first, sq, "e"
    assert_equal 1, mpq.child_question_parts.first.order
    
    sq2 = FactoryGirl.create(:simple_question, :question_setup_id => mpq.question_setup_id)
    
    mpq.add_parts(sq2)
    
    assert_equal 2, mpq.child_question_parts.last.order
  end
  
  test "can't add parts to a published question" do
    mpq = make_multipart_question(:publish => true)
    sq = FactoryGirl.build(:simple_question, :question_setup_id => mpq.question_setup_id)

    assert !mpq.add_parts(sq)    
    assert !mpq.errors.empty?
  end
  
  test "can't add duplicate questions at once" do
    mpq = FactoryGirl.create(:multipart_question)
    sq = FactoryGirl.create(:simple_question, :question_setup_id => mpq.question_setup_id)

    assert !mpq.add_parts([sq, sq])
    assert !mpq.errors.empty?
  end
  
  test "can't add draft w/o setup" do
    mpq = FactoryGirl.create(:multipart_question)
    sq = FactoryGirl.create(:simple_question)

    assert !mpq.add_parts(sq)
    assert !mpq.errors.empty?    
  end

  test "can add a published part without an intro" do
    mpq = FactoryGirl.create(:multipart_question)
    sq1 = FactoryGirl.create(:simple_question, :question_setup_id => mpq.question_setup_id)
    sq2 = make_simple_question(:published => true, :method => :create, :no_setup => true)

    assert mpq.add_parts([sq1, sq2])
    assert mpq.errors.empty?    
  end
  
  test "incoming parts must have the same intro" do
    mpq = FactoryGirl.create(:multipart_question)
    sq1 = FactoryGirl.create(:simple_question, :question_setup_id => mpq.question_setup_id)
    sq2 = make_simple_question(:method => :create)    
    
    assert !mpq.add_parts([sq1, sq2])
    assert !mpq.errors.empty?
  end
  
  test "incoming parts must have the same intro as the multipart" do
    mpq = FactoryGirl.create(:multipart_question)
    sq1 = FactoryGirl.create(:simple_question)

    assert !mpq.add_parts(sq1)
    assert !mpq.errors.empty?
  end
  
  test "multipart without an intro takes on incoming intro" do
    mpq = FactoryGirl.create(:multipart_question, :question_setup => FactoryGirl.create(:question_setup, :content => " "))
    sq = FactoryGirl.create(:simple_question)
    
    old_mpq_setup_id = mpq.question_setup_id
    assert_nothing_raised(ActiveRecord::RecordNotFound) { QuestionSetup.find(old_mpq_setup_id)}
    
    mpq.add_parts(sq)
    assert_equal mpq.question_setup_id, sq.question_setup_id
    
    # test cleanup of orphaned question setup
    assert_raise(ActiveRecord::RecordNotFound) { QuestionSetup.find(old_mpq_setup_id)}
  end
  
  test "cannot add part twice" do
    mpq = FactoryGirl.create(:multipart_question)
    sq = FactoryGirl.create(:simple_question, :question_setup_id => mpq.question_setup_id)
    
    mpq.add_parts(sq)
    assert !mpq.add_parts(sq), 'b'
    assert !mpq.errors.empty?, 'c'
  end
  
  test "can modify setup in a part" do
    # This is allowed b/c the question setup doesn't belong to any published q's.
    mpq = FactoryGirl.create(:multipart_question)
    sq = FactoryGirl.create(:simple_question, :question_setup_id => mpq.question_setup_id)

    sq.update_attributes(:question_setup_attributes => {:content => "test"})
    assert sq.valid?
  end
  
  test "normal publish" do
    mpq = FactoryGirl.create(:multipart_question)
    sq1 = FactoryGirl.create(:simple_question, :question_setup_id => mpq.question_setup_id)
    sq2 = FactoryGirl.create(:simple_question, :question_setup_id => mpq.question_setup_id)
    sq3 = make_simple_question(:no_setup => true, :published => true)
    mpq.add_parts([sq1, sq2, sq3])
    
    user = FactoryGirl.create(:user)
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
    mpq = FactoryGirl.create(:multipart_question)
    sq1 = FactoryGirl.create(:simple_question, :question_setup_id => mpq.question_setup_id)
    sq2 = FactoryGirl.create(:simple_question, :question_setup_id => mpq.question_setup_id)
    sq3 = make_simple_question(:no_setup => true, :published => true)
    mpq.add_parts([sq1, sq2, sq3])

    user = FactoryGirl.create(:user)
    [mpq, sq1].each{|q| q.set_initial_question_roles(user)} # leave sq2 out

    assert !mpq.ready_to_be_published?

    assert mpq.publish!(user).nil?
    assert !mpq.errors.empty?

    assert !mpq.is_published?
    assert !sq1.is_published?
    assert !sq2.is_published?
  end
  
  test "content copy" do
    mpq = FactoryGirl.create(:multipart_question)
    sq1 = FactoryGirl.create(:simple_question, :question_setup_id => mpq.question_setup_id)
    sq2 = FactoryGirl.create(:simple_question, :question_setup_id => mpq.question_setup_id)
    sq3 = make_simple_question(:no_setup => true, :published => true)
    mpq.add_parts([sq1, sq2, sq3])
    
    pre_copy_time = Time.now

    sleep 1 # second
    
    kopy = mpq.content_copy
    
    assert_equal kopy.question_setup.content, mpq.question_setup.content, "a"
    assert_equal kopy.child_question_parts.size, mpq.child_question_parts.size, "b"
    
    (0..kopy.child_question_parts.size-1).each do |ii|
      assert_equal kopy.child_question_parts[ii].order, mpq.child_question_parts[ii].order, "c#{ii}"
      assert_equal kopy.child_question_parts[ii].child_question.content, 
                   mpq.child_question_parts[ii].child_question.content, "d#{ii}"
    end
    
    kopy.save!
    
    # Make sure original didnt' change
    assert mpq.child_question_parts[0].updated_at < pre_copy_time, "e"
  end

  test "merging question setups" do
    mpq = FactoryGirl.create(:multipart_question)
    mpq.question_setup.content = "Something"
    mpq.question_setup.save!

    mpq_blank = FactoryGirl.create(:multipart_question)
    mpq_blank.question_setup.content = ""
    mpq_blank.question_setup.save!

    sq = FactoryGirl.create(:simple_question)
    sq.question_setup.content = "Something"
    sq.question_setup.save!

    sq_different = FactoryGirl.create(:simple_question)
    sq_different.question_setup.content = "Something else"
    sq_different.question_setup.save!

    sq_blank = make_simple_question(:no_setup => true)

    psq = FactoryGirl.create(:simple_question)
    psq.question_setup.content = "Something"
    psq.question_setup.save!
    psq.publish!(FactoryGirl.create(:user))

    psq_different = FactoryGirl.create(:simple_question)
    psq_different.question_setup.content = "Something else"
    psq_different.question_setup.save!
    psq_different.publish!(FactoryGirl.create(:user))

    psq_blank = make_simple_question(:no_setup => true, :published => true)

    mpq0 = mpq.content_copy
    mpq0.save!
    mpq0.add_parts(sq)
    assert_equal mpq0.child_question_parts.size, 1

    mpq1 = mpq.content_copy
    mpq1.save!
    sq_blank0 = sq_blank.content_copy
    sq_blank0.save!
    mpq1.add_parts(sq_blank0)
    assert_equal mpq1.child_question_parts.size, 1
    assert_equal sq_blank0.question_setup.content, "Something"

    mpq2 = mpq.content_copy
    mpq2.save!
    mpq2.add_parts(sq_different)
    assert_equal mpq2.child_question_parts.size, 0
    assert_equal mpq2.question_setup.content, "Something"
    assert_equal sq_different.question_setup.content, "Something else"

    mpq3 = mpq.content_copy
    mpq3.save!
    sq_blank1 = sq_blank.content_copy
    sq_blank1.save!
    mpq3.add_parts([sq, sq_blank1])
    assert_equal mpq3.child_question_parts.size, 2
    assert_equal sq_blank1.question_setup.content, "Something"

    mpq4 = mpq.content_copy
    mpq4.save!
    sq_blank2 = sq_blank.content_copy
    sq_blank2.save!
    mpq4.add_parts([sq, sq_blank2, sq_different])
    assert_equal mpq4.child_question_parts.size, 0
    assert_equal sq_blank2.question_setup.content, ""
    assert_equal sq_different.question_setup.content, "Something else"

    mpq5 = mpq.content_copy
    mpq5.save!
    mpq5.add_parts(psq)
    assert_equal mpq5.child_question_parts.size, 1

    mpq6 = mpq.content_copy
    mpq6.save!
    mpq6.add_parts(psq_blank)
    assert_equal mpq6.child_question_parts.size, 1
    assert_equal mpq6.question_setup.content, "Something"
    assert_nil psq_blank.question_setup

    mpq7 = mpq.content_copy
    mpq7.save!
    mpq7.add_parts(psq_different)
    assert_equal mpq7.child_question_parts.size, 0
    assert_equal mpq7.question_setup.content, "Something"

    mpq8 = mpq.content_copy
    mpq8.save!
    mpq8.add_parts([psq, psq_blank])
    assert_equal mpq8.child_question_parts.size, 2
    assert_equal mpq8.question_setup.content, "Something"
    assert_nil psq_blank.question_setup

    mpq9 = mpq.content_copy
    mpq9.save!
    mpq9.add_parts([psq, psq_blank, psq_different])
    assert_equal mpq9.child_question_parts.size, 0
    assert_equal mpq9.question_setup.content, "Something"
    assert_nil psq_blank.question_setup

    mpq_blank0 = mpq_blank.content_copy
    mpq_blank0.save!
    mpq_blank0.add_parts(sq)
    assert_equal mpq_blank0.child_question_parts.size, 1
    assert_equal mpq_blank0.question_setup.content, "Something"

    mpq_blank1 = mpq_blank.content_copy
    mpq_blank1.save!
    sq_blank3 = sq_blank.content_copy
    sq_blank3.save!
    mpq_blank1.add_parts(sq_blank3)
    assert_equal mpq_blank1.child_question_parts.size, 1

    mpq_blank2 = mpq_blank.content_copy
    mpq_blank2.save!
    mpq_blank2.add_parts(sq_different)
    assert_equal mpq_blank2.child_question_parts.size, 1
    assert_equal mpq_blank2.question_setup.content, "Something else"

    mpq_blank3 = mpq_blank.content_copy
    mpq_blank3.save!
    sq_blank4 = sq_blank.content_copy
    sq_blank4.save!
    mpq_blank3.add_parts([sq, sq_blank4])
    assert_equal mpq_blank3.child_question_parts.size, 2
    assert_equal mpq_blank3.question_setup.content, "Something"
    assert_equal sq_blank4.question_setup.content, "Something"

    mpq_blank4 = mpq_blank.content_copy
    mpq_blank4.save!
    sq_blank5 = sq_blank.content_copy
    sq_blank5.save!
    mpq_blank4.add_parts([sq, sq_blank5, sq_different])
    assert_equal mpq_blank4.child_question_parts.size, 0
    assert_equal mpq_blank4.question_setup.content, ""

    mpq_blank5 = mpq_blank.content_copy
    mpq_blank5.save!
    mpq_blank5.add_parts(psq)
    assert_equal mpq_blank5.child_question_parts.size, 1
    assert_equal mpq_blank5.question_setup.content, "Something"

    mpq_blank6 = mpq_blank.content_copy
    mpq_blank6.save!
    mpq_blank6.add_parts(psq_blank)
    assert_equal mpq_blank6.child_question_parts.size, 1
    assert_equal mpq_blank6.question_setup.content, ""
    assert_nil psq_blank.question_setup

    mpq_blank7 = mpq_blank.content_copy
    mpq_blank7.save!
    mpq_blank7.add_parts(psq_different)
    assert_equal mpq_blank7.child_question_parts.size, 1
    assert_equal mpq_blank7.question_setup.content, "Something else"

    mpq_blank8 = mpq_blank.content_copy
    mpq_blank8.save!
    mpq_blank8.add_parts([psq, psq_blank])
    assert_equal mpq_blank8.child_question_parts.size, 2
    assert_equal mpq_blank8.question_setup.content, "Something"
    assert_nil psq_blank.question_setup

    mpq_blank9 = mpq_blank.content_copy
    mpq_blank9.save!
    mpq_blank9.add_parts([psq, psq_blank, psq_different])
    assert_equal mpq_blank9.child_question_parts.size, 0
    assert_equal mpq_blank9.question_setup.content, ""
    assert_nil psq_blank.question_setup
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
