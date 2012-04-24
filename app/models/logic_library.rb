class LogicLibrary < ActiveRecord::Base
  acts_as_numberable
  has_many :logic_library_versions, :dependent => :destroy
  
  before_destroy :no_versions

  scope :always_required, where(:always_required => true)
  
  def latest_version(include_deprecated = true)
    (include_deprecated ? 
      logic_library_versions :
      logic_library_versions.where(:deprecated => false)).order(:version.desc).first
  end
  
  def self.latest_versions(include_deprecated = true)
    LogicLibrary.all.collect{|library| library.latest_version(include_deprecated)}.compact
  end
  
  def self.latest_required_versions(include_deprecated = true)
    always_required.all.collect{|library| library.latest_version(include_deprecated)}.compact
  end
  
  protected
  
  def no_versions
    logic_library_versions.empty?
  end
  
end
