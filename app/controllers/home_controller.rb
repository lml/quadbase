# Copyright (c) 2011 Rice University.  All rights reserved.

class HomeController < ApplicationController
  skip_before_filter :authenticate_user!
  before_filter :include_jquery
  before_filter :include_jcarousellite, :only => :index
  before_filter :include_mathjax, :only => [:index, :show, :edit, :search]
  
  def index
  end
  
  def shortcut    
    
    if (params[:id] =~ /^q(\d+)(v(\d+))?$/)
      redirect_to question_path(:id => params[:id])
    else    
      ids = params[:id].split("+")
      @questions = []
    
      ids.each do |id|
        raise ActiveRecord::RecordNotFound if !(id =~ /^q(\d+)(v(\d+))?$/)
        @questions.push(Question.from_param(id))
      end
    
      respond_with(@questions)
    end
  end
  
end
