# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class QuestionPartsController < ApplicationController

  respond_to :html, :js

  def destroy
    @part = QuestionPart.find(params[:id])
    raise SecurityTransgression unless present_user.can_destroy?(@part)
    @multipart_question = @part.multipart_question
    @multipart_question.remove_part(@part.child_question)
    @multipart_question.reload
    respond_to do |format|
      format.js
      format.html { redirect_to edit_question_path(@multipart_question) }
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

  def unlock
    @part = QuestionPart.find(params[:question_part_id])
    raise SecurityTransgression unless present_user.can_update?(@part)
    @multipart_question = @part.multipart_question
    @part.unlock!(present_user)
    @multipart_question.reload
    respond_to do |format|
      format.js
      format.html { redirect_to edit_question_path(@multipart_question) }
    end
  end

end
