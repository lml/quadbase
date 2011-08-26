# Copyright (c) 2011 Rice University.  All rights reserved.

class QuestionPartsController < ApplicationController

  respond_to :html, :js

  def destroy
    @part = QuestionPart.find(params[:id])
    raise SecurityTransgression unless present_user.can_destroy?(@part)
    @part.destroy # TODO unlink question setup so can be changed independently
    respond_with(@part) do |format|
      format.js
      format.html { redirect_to edit_question_path(@part.multipart_question) }
    end
  end

  def sort
    sorted_part_ids = params['part']
    return if sorted_part_ids.nil?

    sorted_part_ids.each do |sorted_id|
      part = QuestionPart.find(sorted_id)
      raise SecurityTransgression unless 
        part.can_be_sorted_by?(present_user)
    end
      
    QuestionPart.sort(sorted_part_ids)

    @question = QuestionPart.find(sorted_part_ids.first).multipart_question

    respond_to do |format|
      format.js
      format.html { redirect_to edit_question_path(@question) }
      # HTML won't work anyway due to the sort script using JS
    end
  end

end
