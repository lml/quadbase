# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class Deputization < ActiveRecord::Base
  belongs_to :deputizer, :class_name => "User"
  belongs_to :deputy, :class_name => "User"

  validates_presence_of :deputizer_id, :deputy_id  
  validates_uniqueness_of :deputizer_id, :scope => :deputy_id
  validate :no_self_deputizations
  
  attr_accessible :deputizer_id, :deputy_id

  #############################################################################
  # Access control methods
  #############################################################################

  def can_be_read_by?(user)
    !user.is_anonymous? && (user.id == deputizer_id || user.id == deputy_id)
  end

  def can_be_created_by?(user)
    !user.is_anonymous? && user.id == deputizer.id && user.id != deputy.id
  end

  def can_be_destroyed_by?(user)
    !user.is_anonymous? && (user.id == deputizer_id || user.id == deputy_id)
  end

  
protected

  def no_self_deputizations
    return if deputizer_id != deputy_id
    self.errors.add(:base, "A user cannot be his or her own deputy.")
    false
  end
end
