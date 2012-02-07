# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class VotesController < ApplicationController

  # PUT /votes/up
  def up

    setup_vote_variables

    raise SecurityTransgression unless present_user.can_update?(@vote)

    @vote.thumbs_up = true

    respond_to do |format|
      if @vote.save
        format.html { flash[:notice] = 'Vote added.'; redirect_to(@votable) }
        format.js
      else
        @errors = @vote.errors
        format.html { redirect_to(@votable) }
        format.js { render 'shared/display_flash' }
      end
    end

  end

  # PUT /votes/down
  def down

    setup_vote_variables

    raise SecurityTransgression unless present_user.can_update?(@vote)

    @vote.thumbs_up = false

    respond_to do |format|
      if @vote.save
        format.html { flash[:notice] = 'Vote added.'; redirect_to(@votable) }
        format.js
      else
        @errors = @vote.errors
        format.html { redirect_to(@votable) }
        format.js { render 'shared/display_flash' }
      end
    end

  end

private

  def find_votable
    params.each do |name, value|
      if name =~ /(.+)_id$/
        if $1 == 'question'
          return Question.from_param(value)
        else
          return $1.classify.constantize.find(value)
        end
      end
    end
    nil
  end

  def setup_vote_variables
    @votable = find_votable

    raise SecurityTransgression unless present_user.can_read?(@votable)

    @votes = @votable.votes

    @vote = @votes.find_by_user_id(present_user.id)
    if !@vote
      @vote = Vote.new
      @vote.votable = @votable
      @vote.user = present_user
    end
  end

end
