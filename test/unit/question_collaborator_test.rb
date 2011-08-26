# Copyright (c) 2011 Rice University.  All rights reserved.

require 'test_helper'

class QuestionCollaboratorTest < ActiveSupport::TestCase
  
  fixtures
  self.use_transactional_fixtures = true
  
  test "delete doesn't propagate" do
    c = Factory.create(:question_collaborator)
    c.destroy
    
    assert_nothing_raised {User.find(c.user.id)}
    assert_nothing_raised {Question.find(c.question.id)}
  end
  
  test "can't add collaborator for published question" do
    sq = make_simple_question({:published => true,
                               :method => :create})
    
    assert_raise(ActiveRecord::RecordInvalid) {Factory.create(:question_collaborator, :question => sq)}
  end

  test "can't modify collaborator for published question" do
    q = Factory.create(:simple_question)
    pq = make_simple_question({:published => true,
                               :method => :create})
    c0 = Factory.create(:question_collaborator, :question => q)

    c0.is_author = true
    c0.save!
    
    c1 = Factory.create(:question_collaborator, :question => q)
    c1.is_copyright_holder = true
    c1.save!

    c0.question = pq
    c0.is_copyright_holder = true

    assert c0.question.is_published?
    assert_raise(ActiveRecord::RecordInvalid) {c0.save!}
  end

  test "can't destroy collaborator with roles" do
    q = Factory.create(:simple_question)
    qc0 = Factory.create(:question_collaborator, :question => q)
    qc1 = Factory.create(:question_collaborator, :question => q, :is_author => true)
    qc2 = Factory.create(:question_collaborator, :question => q, :is_copyright_holder => true)
    qc0.destroy
    qc1.destroy
    qc2.destroy
    assert_raise(ActiveRecord::RecordNotFound) { QuestionCollaborator.find(qc0.id) }
    assert_nothing_raised { QuestionCollaborator.find(qc1.id) }
    assert_nothing_raised { QuestionCollaborator.find(qc2.id) }
  end

  test "can't add collaborator twice" do
    user = Factory.create(:user)
    sq = Factory.create(:simple_question)
    assert_nothing_raised {Factory.create(:question_collaborator, :question => sq, :user => user)}
    assert_raise(ActiveRecord::RecordInvalid) {Factory.create(:question_collaborator, :question => sq, :user => user)}
  end
  
#  test "a question must always have at least one collaborator" do
#    flunk "Not yet implemented."
#  end
  
  test "delete destroys dependent assocs" do
    qrr = Factory.create(:question_role_request, :toggle_is_author => true)
    qc = qrr.question_collaborator
    assert QuestionRoleRequest.find_by_question_collaborator_id(qc.id)
    assert qc.destroy
    assert !QuestionRoleRequest.find_by_question_collaborator_id(qc.id)
  end
  
  test "can't mass-assign roles" do
    # roles should only be set when role requests are accepted
    # we don't want folks submitting web requests to change roles

    c = Factory.create(:question_collaborator)
    
    c.update_attributes({:is_author => true, :is_copyright_holder => true})
    
    assert_equal c.is_author, false
    assert_equal c.is_copyright_holder, false
  end
  
  test "new collaborators get next position number" do
    q = Factory.create(:simple_question)
    c0 = Factory.create(:question_collaborator, :question => q)
    c1 = Factory.create(:question_collaborator, :question => q)
    
    assert_equal c0.position, 0
    assert_equal c1.position, 1
    
    Factory.create(:question_collaborator)
    
    c2 = Factory.create(:question_collaborator, :question => q)

    assert_equal c2.position, 2
  end
  
  test "copy roles" do
    q0 = Factory.create(:simple_question)
    q1 = Factory.create(:simple_question)
    c0 = Factory.create(:question_collaborator, :question => q0, :is_author => true)
    QuestionCollaborator.copy_roles(q0, q1)
    c1 = q1.question_collaborators.first
    assert_equal c0.is_author, c1.is_author
    assert_equal c0.is_copyright_holder, c1.is_copyright_holder
    assert_not_equal c0, c1
  end

  test "has request" do
    qr = Factory.create(:question_collaborator)
    assert !qr.has_request?(:author)
    assert !qr.has_request?(:copyright)
    qrr0 = Factory.create(:question_role_request, :question_collaborator => qr, :toggle_is_author => true)
    assert qr.has_request?(:author)
    assert !qr.has_request?(:copyright)
    qrr1 = Factory.create(:question_role_request, :question_collaborator => qr, :toggle_is_copyright_holder => true)
    assert qr.has_request?(:author)
    assert qr.has_request?(:copyright)
    qrr0.destroy
    assert !qr.has_request?(:author)
    assert qr.has_request?(:copyright)
  end

  test "has role" do
    qr = Factory.create(:question_collaborator)
    assert !qr.has_role?(:author)
    assert !qr.has_role?(:copyright)
    assert !qr.has_role?(:any)
    assert qr.has_role?(:is_listed)
    qr.is_copyright_holder = true
    qr.save!
    assert !qr.has_role?(:author)
    assert qr.has_role?(:copyright)
    assert qr.has_role?(:any)
    assert qr.has_role?(:is_listed)
  end

end
