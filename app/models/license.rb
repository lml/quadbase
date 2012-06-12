# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class License < ActiveRecord::Base
  has_many :questions

  validates_presence_of :short_name, :long_name, :url
  validates_uniqueness_of :short_name, :long_name, :url
  validates_uniqueness_of :is_default, :allow_blank => true
  validates_as_url :url, :unless => Rails.env.test?

  before_destroy :destroyable?
  before_create :make_default_if_first!

  validate :changeable?, :on => :update
  validate :no_licenses_yet, :on => :create

  attr_accessible :short_name, :long_name, :url, :agreement_partial_name

  def self.default
    where{is_default == true}.first
  end

  def make_default!
    old_default = License.default
    return if old_default == self

    transaction do
      if !old_default.nil?
        old_default.is_default = false        
        old_default.save!
      end

      self.is_default = true
      self.save!
    end
  end
  
protected

  # A license is destroyable if it isn't linked to any questions
  def destroyable?
    return if questions.empty?
    errors.add(:base, "Changes cannot be made to the selected license because " +
                      "existing questions are using it.")
    false
  end

  # A license is changeable if it isn't linked to any questions, or if the only 
  # change was to the agreement partial name or to the is_default column
  def changeable?
    return if questions.empty?
    return if (self.changed - ['agreement_partial_name', 'is_default']).empty?
    errors.add(:base, "Changes cannot be made to the selected license because " +
                      "existing questions are using it.")
    false
  end
  
  # Currently, quadbase is a 1-license system.  See /plans.txt for background
  # on this decision.
  def no_licenses_yet
    return if License.count == 0
    errors.add(:base, "Currently, only one license is allowed in Quadbase.")
    false
  end

  def make_default_if_first!
    self.is_default = true if License.default.blank?
  end

end
