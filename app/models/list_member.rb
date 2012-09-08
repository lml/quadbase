# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class ListMember < ActiveRecord::Base
  belongs_to :user
  belongs_to :list
  
  validate :validate_max_one_default_list_per_user
  validates_uniqueness_of :user_id,
                            :scope => :list_id,
                            :message => "This user is already a member of this list."

  after_create :check_and_set_default_list

  after_destroy :destroy_memberless_list

  attr_accessible :user, :list, :user_id
  
  def make_default!
    return if is_default
    
    old_default_list_member = ListMember.default_for_user(self.user)
    self.is_default = true

    if (old_default_list_member.nil?)
        self.save!
    else
        old_default_list_member.is_default = false
        ListMember.transaction do
          old_default_list_member.save!
          self.save!
        end        
    end   
  end
  
  def self.default_for_user(user)
    ListMember.defaults_for_user(user).first
  end
  
  def self.all_for_user(user)
    ListMember.where{user_id == user.id}.all
  end

  def check_and_set_default_list
    if List.default_for_user(self.user) == nil
      self.make_default!
    end
  end

  def destroy_memberless_list
    if list.list_members.empty?
      list.destroy
    end
  end
  
  #############################################################################
  # Access control methods
  #############################################################################

  def can_be_created_by?(user)
    !user.is_anonymous? && list.is_member?(user)
  end

  def can_be_updated_by?(user)
    !user.is_anonymous? && user == self.user
  end
  
  def can_be_destroyed_by?(user)
    !user.is_anonymous? && list.is_member?(user)
  end
    
protected

  scope :defaults_for_user, lambda { |user| 
    where{(user_id == user.id) & (is_default == true)}
  }  
  
  # Ideally, we'd want for there to always be exactly one default list
  # per user.  However, when we switch the default from one list_member
  # to another, there is a brief moment when none of a user's lists are
  # the default.
  def validate_max_one_default_list_per_user
    # have to remember to count the "self" object that hasn't yet been saved
    return if (ListMember.defaults_for_user(user).count + (self.is_default ? 1 : 0)) <= 1
    
    errors.add(:base, "A user cannot have multiple default lists.")
    false
  end
end
