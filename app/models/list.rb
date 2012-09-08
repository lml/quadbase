# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class List < ActiveRecord::Base
  has_many :list_members, :dependent => :destroy
  has_many :members, :through => :list_members, :source => :user
  
  has_many :list_questions, :dependent => :destroy
  has_many :questions, :through => :list_questions

  has_one :comment_thread, :as => :commentable, :dependent => :destroy
  before_validation :build_comment_thread, :on => :create
  validates_presence_of :comment_thread
  
  accepts_nested_attributes_for :list_members, :allow_destroy => true
  accepts_nested_attributes_for :list_questions, :allow_destroy => true

  attr_accessible :name, :list_members_attributes, :list_questions_attributes
  
  # Returns the default list for the specified user, or nil if it doesn't exist.  
  def self.default_for_user(user)    
    default_member = ListMember.default_for_user(user)
    default_member.nil? ? nil : default_member.list
  end

  # Returns the default list for the specified user.  If no such list
  # exists, makes a new one and returns it.  
  def self.default_for_user!(user)    
    default_member = ListMember.default_for_user(user)
    
    if default_member.nil?
      new_list = List.create(:name => user.full_name + "'s List")
      default_member = ListMember.create(:user => user, :list => new_list)
      default_member.make_default!
    end
    default_member.list
  end
  
  
  def self.all_for_user(user)
    ListMember.all_for_user(user).collect{|wm| wm.list}
  end
  
  def is_default_for_user?(user)
    default_member = ListMember.default_for_user(user)
    return false if default_member.nil?
    self == default_member.list
  end
  
  def add_question!(question)
    ListQuestion.create(:list => self, :question => question)
  end
  
  def add_member!(member)
    ListMember.create(:list => self, :user => member)
  end
  
  def is_member?(user)
    members.include?(user)
  end

  def has_question?(question, reload=true)
    questions(reload).include?(question)
  end

  def can_be_joined_by?(user)
    !is_member?(user)
  end
  
  #############################################################################
  # Access control methods
  #############################################################################

  def can_be_read_by?(user)
    !user.is_anonymous? && is_member?(user)
  end
    
  def can_be_created_by?(user)
    !user.is_anonymous?
  end
  
  def can_be_updated_by?(user)
    !user.is_anonymous? && is_member?(user)
  end
  
  def can_be_destroyed_by?(user)
    !user.is_anonymous? && is_member?(user)
  end

end
