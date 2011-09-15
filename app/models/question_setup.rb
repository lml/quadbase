# Copyright (c) 2011 Rice University.  All rights reserved.

class QuestionSetup < ActiveRecord::Base
  include ContentParseAndCache
  include AssetMethods
  
  has_many :questions

  has_many :attachable_assets, :as => :attachable
  has_many :assets, :through => :attachable_assets
  
  validate :validate_content_change_allowed

  attr_accessible :content
  
  def content_copy
    kopy = QuestionSetup.new(:content => content)
    self.attachable_assets.each {|aa| kopy.attachable_assets.push(aa.content_copy) }
    kopy
  end
  
  def content_change_allowed?
    questions.select{|q| q.is_published?}.empty?
  end
  
  def destroy_if_unattached
    # Force a reload to make sure the association is up to date
    destroy if questions(true).empty?
  end
    
  #############################################################################
  # Access control methods
  #############################################################################
  
  def can_be_updated_by?(user)
    !user.is_anonymous? && content_change_allowed? && questions.any?{|q| user.can_update?(q)}
  end  
  
protected

  def validate_content_change_allowed
    return if content_unchanged? || content_change_allowed?
    self.errors.add(:content, "cannot be changed because it is linked to published questions.")
  end

end
