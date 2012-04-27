class LogicLibraryVersion < ActiveRecord::Base
  belongs_to :logic_library  
  before_validation :assign_version, :on => :create

  before_update :not_used
  before_update :verify_latest
  before_save :uglify_code
  before_destroy :not_used
  before_destroy :verify_latest

  def name
    logic_library.name + " v" + version.to_s
  end
  
  def logics_using
    Logic.where(:required_logic_library_version_ids.matches => "%'#{id}'%")
  end

  protected
  
  def assign_version
    self.version = LogicLibraryVersion.where(:logic_library => logic_library).count + 1
  end
  
  def not_used
    # check that there are no logics using this version
    errors.add(:base, "This version cannot be changed or deleted because it is used by a question") if
      logics_using.any?
    errors.none?
  end
  
  def verify_latest
    errors.add(:base, "Non-latest versions cannot be changed or destroyed") if
      logic_library.latest_version != self
    errors.none?
  end
  
  def uglify_code
    self.minified_code = Uglifier.compile(code)
  end
  
end
