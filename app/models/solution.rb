# Copyright (c) 2011 Rice University.  All rights reserved.

class Solution < ActiveRecord::Base
  include ContentParseAndCache
  include AssetMethods

  belongs_to :question
  belongs_to :creator, :class_name => "User"

  has_many :votes, :as => :votable

  has_many :attachable_assets, :as => :attachable
  has_many :assets, :through => :attachable_assets

  has_one :comment_thread, :as => :commentable, :dependent => :destroy
  before_validation :build_comment_thread, :on => :create
  validates_presence_of :question, :creator, :comment_thread

  attr_accessible :content, :explanation, :is_visible
  
  scope :visible_for, lambda { |user|
    where(:creator_id.eq % user.id | :is_visible.eq % true)
  }

  def has_content?
    !content_html.blank? || !explanation.nil?
  end

  def is_modified?
    updated_at != created_at
  end

  def set_created_at(time)
    update_attribute(:created_at, time)
    update_attribute(:updated_at, time)
  end

  #############################################################################
  # Access control methods
  #############################################################################

  def can_be_read_by?(user)
    !user.is_anonymous? && user.can_read?(question) && (is_visible || user == creator)
  end

  def can_be_created_by?(user)
    !user.is_anonymous? && user.can_read?(question)
  end

  def can_be_updated_by?(user)
    !user.is_anonymous? && user == creator
  end

  def can_be_destroyed_by?(user)
    !user.is_anonymous? && (user == creator || user.is_administrator?)
  end

  def can_be_voted_on_by?(user)
    can_be_read_by?(user) && user != creator
  end

end
