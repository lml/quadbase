# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class Vote < ActiveRecord::Base

  belongs_to :votable, :polymorphic => true
  belongs_to :user

  validates_uniqueness_of :user_id, :scope => :votable_id

  attr_accessible # none

  scope :positive, where{thumbs_up == true}
  scope :negative, where{thumbs_up == false}

  def self.order_by_votes(votable_array)
    votable_array.sort { |a, b|
      b.votes.positive.size - b.votes.negative.size <=>
      a.votes.positive.size - a.votes.negative.size
    }
  end

  def self.is_highly_voted?(votable)
    (votable.votes.positive.size - votable.votes.negative.size) > 0
  end

  #############################################################################
  # Access control methods
  #############################################################################

  def can_be_updated_by?(user)
    !user.is_anonymous? && user == self.user
  end

end
