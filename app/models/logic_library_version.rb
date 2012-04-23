class LogicLibraryVersion < ActiveRecord::Base
  belongs_to :logic_library  
  before_validation :assign_version, :on => :create
  
  before_update :not_used
  before_destroy :not_used
  before_destroy :verify_latest
  
  protected
  
  def assign_version
    self.version = LogicLibraryVersion.where(:logic_library => logic_library).count + 1
  end
  
  def not_used
    # check that there are no logics using this version
    raise NotYetImplemented
  end
  
  def verify_latest
    logic_library.latest_version == self
  end
  
end
