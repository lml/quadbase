# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class ProjectMemberTest < ActiveSupport::TestCase

  fixtures
  self.use_transactional_fixtures = true

  test "can't mass-assign is_default" do
    wm = ProjectMember.new(:is_default => true)
    assert !wm.is_default
  end

  test "default for user" do 
    wm1 = FactoryGirl.create(:project_member, :is_default => true)
    wm2 = FactoryGirl.create(:project_member, :user => wm1.user)

    assert_equal wm1, ProjectMember.default_for_user(wm1.user)
  end

  test "make default" do
    wm1 = FactoryGirl.create(:project_member, :is_default => true)
    wm2 = FactoryGirl.create(:project_member, :user => wm1.user)
    
    assert wm1.is_default, "a"
    assert !wm2.is_default,  "b"
    
    wm2.make_default!
    
    wm1.reload
    wm2.reload
    
    assert !wm1.is_default, "c"
    assert wm2.is_default, "d" 
  end
  
  test "can't have more than 1 default" do 
    wm1 = FactoryGirl.create(:project_member, :is_default => true)
    
    assert_raise(ActiveRecord::RecordInvalid) { 
      FactoryGirl.create(:project_member, :user => wm1.user, :is_default => true)
    }
  end

  test "can't add member twice" do
    user = FactoryGirl.create(:user)
    project = FactoryGirl.create(:project)
    assert_nothing_raised {FactoryGirl.create(:project_member, :project => project, :user => user)}
    assert_raise(ActiveRecord::RecordInvalid) {FactoryGirl.create(:project_member, :project => project, :user => user)}
  end

  test "removing last member destroys project" do
    wm0 = FactoryGirl.create(:project_member)
    w = wm0.project
    wm1 = FactoryGirl.create(:project_member, :project => w)
    wm0.destroy
    assert_nothing_raised { Project.find(w.id) }
    wm1.destroy
    assert_raise(ActiveRecord::RecordNotFound) { Project.find(w.id) }
  end

end
