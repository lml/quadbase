# Copyright (c) 2011 Rice University.  All rights reserved.

class InboxController < ApplicationController
  
  before_filter { select_tab(:inbox) }
  before_filter :include_jquery

  def index
  end

end
