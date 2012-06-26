# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class QuestionCollaboratorTest < ActiveSupport::TestCase
  
  fixtures
  self.use_transactional_fixtures = true
  
  setup do
    @question = FactoryGirl.create(:simple_question)
    @first_question_collaborator = FactoryGirl.create(:question_collaborator, :question => @question)
    # Since there are no other role holders yet, creating this request will grant the role
    FactoryGirl.create(:question_role_request, :question_collaborator => @first_question_collaborator, :toggle_is_author => true)
  end
  
  test "delete doesn't propagate" do
    c = FactoryGirl.create(:question_collaborator)
    c.destroy
    
    assert_nothing_raised {User.find(c.user.id)}
    assert_nothing_raised {Question.find(c.question.id)}
  end
  
  test "can't add collaborator for published question" do
    sq = make_simple_question({:published => true,
                               :method => :create})
    
    assert_raise(ActiveRecord::RecordInvalid) {FactoryGirl.create(:question_collaborator, :question => sq)}
  end

  test "can't modify collaborator for published question" do
    q = FactoryGirl.create(:simple_question)
    pq = make_simple_question({:published => true,
                               :method => :create})
    c0 = FactoryGirl.create(:question_collaborator, :question => q)

    c0.is_author = true
    c0.save!
    
    c1 = FactoryGirl.create(:question_collaborator, :question => q)
    c1.is_copyright_holder = true
    c1.save!

    c0.question = pq
    c0.is_copyright_holder = true

    assert c0.question.is_published?
    assert_raise(ActiveRecord::RecordInvalid) {c0.save!}
  end

  test "can't destroy collaborator with roles" do
    q = FactoryGirl.create(:simple_question)
    qc0 = FactoryGirl.create(:question_collaborator, :question => q)
    qc1 = FactoryGirl.create(:question_collaborator, :question => q, :is_author => true)
    qc2 = FactoryGirl.create(:question_collaborator, :question => q, :is_copyright_holder => true)
    qc0.destroy
    qc1.destroy
    qc2.destroy
    assert_raise(ActiveRecord::RecordNotFound) { QuestionCollaborator.find(qc0.id) }
    assert_nothing_raised { QuestionCollaborator.find(qc1.id) }
    assert_nothing_raised { QuestionCollaborator.find(qc2.id) }
  end

  test "can't add collaborator twice" do
    user = FactoryGirl.create(:user)
    sq = FactoryGirl.create(:simple_question)
    assert_nothing_raised {FactoryGirl.create(:question_collaborator, :question => sq, :user => user)}
    assert_raise(ActiveRecord::RecordInvalid) {FactoryGirl.create(:question_collaborator, :question => sq, :user => user)}
  end
  
  test "delete destroys dependent assocs" do
    qc = FactoryGirl.create(:question_collaborator, :question => @question)
    qrr = FactoryGirl.create(:question_role_request, :question_collaborator => qc, :toggle_is_author => true)

    assert QuestionRoleRequest.find_by_question_collaborator_id(qc.id), "a"
    assert qc.destroy
    assert !QuestionRoleRequest.find_by_question_collaborator_id(qc.id), "b"
  end
  
  test "can't mass-assign roles" do
    # roles should only be set when role requests are accepted
    # we don't want folks submitting web requests to change roles

    c = FactoryGirl.create(:question_collaborator)
    
    c.update_attributes({:is_author => true, :is_copyright_holder => true})
    
    assert_equal c.is_author, false
    assert_equal c.is_copyright_holder, false
  end
  
  test "new collaborators get next position number" do
    q = FactoryGirl.create(:simple_question)
    c0 = FactoryGirl.create(:question_collaborator, :question => q)
    c1 = FactoryGirl.create(:question_collaborator, :question => q)
    
    assert_equal c0.position, 0
    assert_equal c1.position, 1
    
    FactoryGirl.create(:question_collaborator)
    
    c2 = FactoryGirl.create(:question_collaborator, :question => q)

    assert_equal c2.position, 2
  end
  
  test "copy roles" do
    q0 = FactoryGirl.create(:simple_question)
    q1 = FactoryGirl.create(:simple_question)
    c0 = FactoryGirl.create(:question_collaborator, :question => q0, :is_author => true)
    QuestionCollaborator.copy_roles(q0, q1)
    c1 = q1.question_collaborators.first
    assert_equal c0.is_author, c1.is_author
    assert_equal c0.is_copyright_holder, c1.is_copyright_holder
    assert_not_equal c0, c1
  end

  test "has request" do
    qc = FactoryGirl.create(:question_collaborator, :question => @question)
    assert !qc.has_request?(:author)
    assert !qc.has_request?(:copyright)
    qrr0 = FactoryGirl.create(:question_role_request, :question_collaborator => qc, :toggle_is_author => true)
    assert qc.has_request?(:author)
    assert !qc.has_request?(:copyright)
    qrr1 = FactoryGirl.create(:question_role_request, :question_collaborator => qc, :toggle_is_copyright_holder => true)
    assert qc.has_request?(:author)
    assert qc.has_request?(:copyright)
    qrr0.destroy
    assert !qc.has_request?(:author)
    assert qc.has_request?(:copyright)
  end

  test "has role" do
    qr = FactoryGirl.create(:question_collaborator)
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
