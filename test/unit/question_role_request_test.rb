# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class QuestionRoleRequestTest < ActiveSupport::TestCase

  fixtures
  self.use_transactional_fixtures = true

  test "can't mass-assign requestor" do
    user = FactoryGirl.create(:user)
    qrr = QuestionRoleRequest.new(:requestor => user)
    assert qrr.requestor != user
  end

  test "duplicate requests for same toggle not allowed" do
    qc = FactoryGirl.create(:question_collaborator)

    assert_nothing_raised {
      FactoryGirl.create(:question_role_request, :toggle_is_author => true, :question_collaborator => qc)
    }

    assert_raise(ActiveRecord::RecordInvalid) {
      FactoryGirl.create(:question_role_request, :toggle_is_author => true, :question_collaborator => qc)
    }
    
    assert_nothing_raised {
      FactoryGirl.create(:question_role_request, :toggle_is_copyright_holder => true, :question_collaborator => qc)
    }
    
    assert_raise(ActiveRecord::RecordInvalid) {
      FactoryGirl.create(:question_role_request, :toggle_is_copyright_holder => true, :question_collaborator => qc)
    }
  end

  test "valid request" do
    assert_nothing_raised { FactoryGirl.create(:question_collaborator) }
    assert_raise(ActiveRecord::RecordInvalid) {
      FactoryGirl.create(:question_role_request, :toggle_is_author => false,
                                             :toggle_is_copyright_holder => false)
    }
    assert_raise(ActiveRecord::RecordInvalid) {
      FactoryGirl.create(:question_role_request, :toggle_is_author => true,
                                             :toggle_is_copyright_holder => true)
    }
  end
  
  test "can be create by" do
    qc1 = FactoryGirl.create(:question_collaborator, :is_author => true)
    qc2 = FactoryGirl.create(:question_collaborator, :question => qc1.question)
    
    qrr = FactoryGirl.build(:question_role_request, :question_collaborator => qc2, :toggle_is_author => true)
    
    assert qc1.user.can_create?(qrr)    
    assert !qc2.user.can_create?(qrr)    
  end
  
  test "can be approved or vetoed by" do
    qc1 = FactoryGirl.create(:question_collaborator, :is_author => true)
    qc1a = FactoryGirl.create(:question_collaborator, :is_author => true, :question => qc1.question)
    qc2 = FactoryGirl.create(:question_collaborator, :question => qc1.question)
    
    qrr = FactoryGirl.build(:question_role_request, :question_collaborator => qc2, :toggle_is_author => true)
    qrr.requestor = qc1.user
    
    assert qrr.can_be_approved_by?(qc1.user)
    assert qrr.can_be_vetoed_by?(qc1.user)
    assert qrr.can_be_approved_by?(qc1a.user)
    assert qrr.can_be_vetoed_by?(qc1a.user)
    assert !qrr.can_be_approved_by?(qc2.user)
    assert !qrr.can_be_vetoed_by?(qc2.user)
  end
  
  test "can be accepted or rejected by" do
    qc1 = FactoryGirl.create(:question_collaborator, :is_author => true)
    qc2 = FactoryGirl.create(:question_collaborator, :question => qc1.question)
    
    qrr = FactoryGirl.build(:question_role_request, :question_collaborator => qc2, :toggle_is_author => true)
    
    assert qrr.can_be_accepted_by?(qc2.user)
    assert qrr.can_be_rejected_by?(qc2.user)
    assert !qrr.can_be_accepted_by?(qc1.user)
    assert !qrr.can_be_rejected_by?(qc1.user)
  end
  
  test "can be destroyed by" do
    qc1 = FactoryGirl.create(:question_collaborator, :is_author => true)
    qc2 = FactoryGirl.create(:question_collaborator, :question => qc1.question)
    
    qrr = FactoryGirl.build(:question_role_request, :question_collaborator => qc2, :toggle_is_author => true)
    qrr.requestor = qc1.user
    
    assert qc1.user.can_destroy?(qrr)
    assert !qc2.user.can_destroy?(qrr)    
  end
  
  test "drops role" do
    qc = FactoryGirl.create(:question_collaborator, :is_author => true)
    qrr = FactoryGirl.build(:question_role_request, :question_collaborator => qc, :toggle_is_author => true)
    
    assert qrr.drops_role?
    
    qc1 = FactoryGirl.create(:question_collaborator, :is_author => false)
    qrr1 = FactoryGirl.build(:question_role_request, :question_collaborator => qc1, :toggle_is_author => true)
    qrr1.accept!
    
    assert !qrr1.drops_role?
  end

end
