# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :lockable, :confirmable, 
         :recoverable, :rememberable, :trackable, :validatable
         
  has_many :question_collaborators
  has_many :list_members
  has_many :lists, :through => :list_members
  has_many :published_questions,
           :class_name => "Question",
           :foreign_key => "publisher_id"

  has_many :comments
  has_many :comment_thread_subscriptions

  has_one :user_profile
  accepts_nested_attributes_for :user_profile
  
  # A user can appoint deputies who can do most things that this user can do
  # We have has_many relationships pointing to a user's deputies as well as
  # those who have deputized this user.
  has_many :owned_deputizations,
           :class_name => "Deputization",
           :foreign_key => "deputizer_id"
  has_many :deputies,
           :through => :owned_deputizations
  
  has_many :received_deputizations,
           :class_name => "Deputization",
           :foreign_key => "deputy_id"
  has_many :deputizers,
           :through => :received_deputizations

  validates_presence_of :first_name, :last_name, :username, :user_profile
  validates_uniqueness_of :username, :case_sensitive => false
  validates_length_of :username, :in => 3..40
  validates_format_of :username, :with => /^[A-Za-z\d_]+$/  # alphanum + _
  validate :validate_username_unchanged, :on => :update

  # These are the attributes the user can modify
  attr_accessible :email, :password, :password_confirmation, :remember_me,
                  :first_name, :last_name, :user_profile_attributes
  
  before_validation :build_user_profile, :on => :create
  before_create :make_first_user_an_admin
  before_update :validate_at_least_one_admin

  scope :active_users, where{disabled_at == nil}
  scope :administrators, where{is_administrator == true}
  scope :active_administrators, administrators.merge(active_users)
  scope :subscribers_for, lambda { |comment_thread|
    joins{comment_thread_subscriptions}.where{comment_thread_subscriptions.comment_thread_id == comment_thread.id}
  }
  
  def full_name
    first_name + " " + last_name
  end
  
  def is_administrator?
    is_administrator
  end

  def is_confirmed?
    !confirmed_at.nil?
  end

  def is_disabled?
    !disabled_at.nil?
  end
  
  def disable!
    update_attribute(:disabled_at, Time.current)
  end

  def enable!
    update_attribute(:disabled_at, nil)
  end
  
  def is_anonymous?
    false
  end

  # INBOX COUNTS ARE CURRENTLY INACCURATE AND HAVE BEEN DEACTIVATED
  # def inbox_count
  #   # Rails bug? The below fails unless you wrap question_collaborators in an array,
  #   # even though question_collaborators IS an array
  #   Array.new(question_collaborators).sum {|qc| qc.question_role_requests.size} +
  #   unread_message_count
  # end

  def question_role_requests
    question_collaborators.collect{|qc| qc.question_role_requests}.flatten
  end
  
  def is_deputy_for?(user)
    received_deputizations.any?{|d| d.deputizer_id == user.id}
  end
  
  # Access control redirect methods
  
  def can_read?(resource)
    resource.can_be_read_by?(self)
  end
  
  def can_create?(resource)
    resource.can_be_created_by?(self)
  end
  
  def can_update?(resource)
    resource.can_be_updated_by?(self)
  end
    
  def can_destroy?(resource)
    resource.can_be_destroyed_by?(self)
  end

  def can_vote_on?(resource)
    resource.can_be_voted_on_by?(self)
  end

  def can_join?(container_type, container_id)
    case container_type
    when 'question'
      return Question.find(container_id).can_be_joined_by?(self)
    when 'list'
      return List.find(container_id).can_be_joined_by?(self)
    when 'message'
      return Message.find(container_id).can_be_joined_by?(self)
    end
  end
  
  def can_tag?(resource)
    resource.can_be_tagged_by?(self)
  end

  # Can't destroy users
  def destroy
  end

  # Can't delete users
  def delete
  end
    
private 

  def make_first_user_an_admin
    if User.count == 0
      self.is_administrator = true
    end
  end
  
  def validate_username_unchanged
    return if username == username_was
    errors.add(:base, "Usernames cannot be changed.")
    false
  end

  def validate_at_least_one_admin
    only_one_active_admin = User.active_administrators.count == 1
    was_admin = is_administrator_was
    was_disabled = !disabled_at_was.nil?
    return if !only_one_active_admin ||
              was_disabled || !was_admin ||
              (is_administrator? && !is_disabled?)
    errors.add(:base, "Quadbase must have at least one admin.")
    false
  end

  def self.search(type, text)
    return User.none if text.blank?
    
    # Note: % is the wildcard. This allows the user to search
    # for stuff that "begins with" but not "ends with".
    case type
    when 'Name'
      u = User.scoped
      text.gsub(/[%,]/, '').split.each do |t|
        next if t.blank?
        query = t + '%'
        u = u.where{(first_name =~ query) | (last_name =~ query)}
      end
      return u
    when 'Username'
      query = text.gsub('%', '') + '%'
      return where{username =~ query}
    when 'Email'
      query = text.gsub('%', '') + '%'
      return where{email =~ query}
    else # All
      u = User.scoped
      text.gsub(/[%,]/, '').split.each do |t|
        next if t.blank?
        query = t + '%'
        u = u.where{(first_name =~ query) | (last_name =~ query) |
                    (username =~ query) | (email =~ query)}
      end
      return u
    end
  end
  
end
