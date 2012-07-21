# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class LogicLibraryVersion < ActiveRecord::Base
  # default_scope order{version.asc}
  
  belongs_to :logic_library  
  before_validation :assign_version, :on => :create

  before_update :not_used
  before_update :verify_latest
  before_save :uglify_code
  before_destroy :not_used
  before_destroy :verify_latest
  
  after_save :send_to_bullring
  
  scope :ordered, order{version.asc}
  attr_accessible :code, :deprecated

  def name
    logic_library.name + " v." + version.to_s
  end
  
  def logics_using
    Logic.where{required_logic_library_version_ids =~ "%'#{id}'%"}
  end
  
  def v_dot
    "v.#{version}"
  end
  
  def send_to_bullring
    Bullring.add_library(id.to_s, code)
  end

  protected
  
  def assign_version
    self.version = LogicLibraryVersion.where{logic_library_id == my{logic_library.id}}.count + 1
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
