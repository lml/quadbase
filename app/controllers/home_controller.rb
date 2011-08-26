# Copyright (c) 2011 Rice University.  All rights reserved.

class HomeController < ApplicationController
  skip_before_filter :authenticate_user!
  before_filter :include_jquery
  before_filter :include_jcarousellite, :only => :index
  before_filter :include_mathjax, :only => [:index, :show, :edit, :search]
  
  def index
  end
  
end
