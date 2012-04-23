class LogicLibrary < ActiveRecord::Base
  acts_as_numberable
  has_many :logic_library_versions, :dependent => :destroy
  
  before_destroy :no_versions
  
  def latest_version
    :logic_library_versions.order(:version.desc).first
  end
  
  protected
  
  def no_versions
    logic_library_versions.empty?
  end
  
end
