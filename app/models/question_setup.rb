# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class QuestionSetup < ActiveRecord::Base
  include ContentParseAndCache
  include AssetMethods
  include VariatedContentHtml
  
  has_many :questions

  has_many :attachable_assets, :as => :attachable, :dependent => :destroy
  has_many :assets, :through => :attachable_assets
  
  has_one :logic, :as => :logicable, :dependent => :destroy
  
  validate :validate_content_change_allowed

  attr_accessible :content, :logic_attributes
  
  before_save :clear_empty_logic
  
  accepts_nested_attributes_for :logic
  
  def content_copy
    kopy = QuestionSetup.new(:content => content)
    self.attachable_assets.each {|aa| kopy.attachable_assets.push(aa.content_copy) }
    kopy.logic = self.logic.content_copy if !self.logic.nil?
    kopy
  end
  
  def content_change_allowed?
    questions.select{|q| q.is_published?}.empty?
  end
  
  def destroy_if_unattached
    # Force a reload to make sure the association is up to date
    destroy if questions(true).empty?
  end
  
  def variate!(variator)
    variator.run(logic)
    @variated_content_html = variator.fill_in_variables(content_html)
  end
  
  def is_empty?
    content.blank? && (logic.nil? || logic.empty?)
  end

  def merge(qs)
    # If the given question setup can be merged with self without losing content
    # or changing any published questions, returns the result of merging the
    # two setups. Otherwise, returns nil.
    return self if self == qs
    same_content = content == qs.content
    if content.blank? || (same_content && content_change_allowed?)
      return qs
    elsif qs.content.blank? || (same_content && qs.content_change_allowed?)
      return self
    end
    nil
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
  
  def clear_empty_logic
    if !logic.nil? && logic.empty?
      logic.destroy 
      self.logic = nil
    end
  end

end
