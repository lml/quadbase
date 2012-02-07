# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class InboxController < ApplicationController
  
  before_filter { select_tab(:inbox) }
  before_filter :include_jquery

  def index
  end

end
