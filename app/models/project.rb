# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class Project < ActiveRecord::Base
  has_many :project_members, :dependent => :destroy
  has_many :members, :through => :project_members, :source => :user
  
  has_many :project_questions, :dependent => :destroy
  has_many :questions, :through => :project_questions

  has_one :comment_thread, :as => :commentable, :dependent => :destroy
  before_validation :build_comment_thread, :on => :create
  validates_presence_of :comment_thread
  
  accepts_nested_attributes_for :project_members, :allow_destroy => true
  accepts_nested_attributes_for :project_questions, :allow_destroy => true

  attr_accessible :name, :project_members_attributes, :project_questions_attributes
  
  # Returns the default project for the specified user, or nil if it doesn't exist.  
  def self.default_for_user(user)    
    default_member = ProjectMember.default_for_user(user)
    default_member.nil? ? nil : default_member.project
  end

  # Returns the default project for the specified user.  If no such project
  # exists, makes a new one and returns it.  
  def self.default_for_user!(user)    
    default_member = ProjectMember.default_for_user(user)
    
    if default_member.nil?
      new_project = Project.create(:name => user.full_name + "'s Project")
      default_member = ProjectMember.create(:user => user, :project => new_project)
      default_member.make_default!
    end
    default_member.project
  end
  
  def self.all_for_user(user)
    Project.default_for_user!(user) if ProjectMember.all_for_user(user).empty?
    ProjectMember.all_for_user(user).collect{|wm| wm.project}
  end
  
  def is_default_for_user?(user)
    default_member = ProjectMember.default_for_user(user)
    return false if default_member.nil?
    self == default_member.project
  end
  
  def add_question!(question)
    ProjectQuestion.create(:project => self, :question => question)
  end
  
  def add_member!(member)
    ProjectMember.create(:project => self, :user => member)
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
