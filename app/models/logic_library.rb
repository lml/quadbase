# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class LogicLibrary < ActiveRecord::Base
  acts_as_numberable
  has_many :logic_library_versions, :dependent => :destroy
  
  before_destroy :no_versions

  scope :always_required, where{always_required == true}
  scope :ordered, order{number.asc}
  
  def latest_version(include_deprecated = true)
    (include_deprecated ?
      logic_library_versions :
      logic_library_versions.where{deprecated == false})
    .order{version.desc}.first
  end
  
  def self.latest_versions(include_deprecated = true)
    LogicLibrary.all.collect{|library| library.latest_version(include_deprecated)}.compact
  end
  
  def self.latest_required_versions(include_deprecated = true)
    always_required.all.collect{|library| library.latest_version(include_deprecated)}.compact
  end
  
  protected
  
  def no_versions
    errors.add(:base, "This library cannot be destroyed because it has versions") if 
      !logic_library_versions.empty?
    errors.none?
  end
  
end
