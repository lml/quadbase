# Copyright (c) 2011 Rice University.  All rights reserved.

class QuestionDependencyPairsController < ApplicationController

  respond_to :js

  def create
    pair = QuestionDependencyPair.new(params[:question_dependency_pair])

    raise SecurityTransgression unless present_user.can_create?(pair)

    @part = QuestionPart.find(params[:question_part_id])

    respond_to do |format|
      if pair.save
        format.js
      else
        flash[:alert] = pair.errors.values.to_sentence
        format.js { render :template => 'shared/display_flash' }
        format.json { render :json => pair.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    pair = QuestionDependencyPair.find(params[:id])
    raise SecurityTransgression unless present_user.can_destroy?(pair)
    pair.destroy    
    @part = QuestionPart.find(params[:question_part_id])
  end

end
