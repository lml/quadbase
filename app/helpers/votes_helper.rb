# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

module VotesHelper

  def get_vote_for(votable, user)
    Vote.find_by_votable_type_and_votable_id_and_user_id(votable.class.to_s, votable.id, user.id)
  end

  def cannot_vote_message(votable, user)
    if user.is_anonymous?
      "You must login to vote."
    else
      "You cannot vote for your own " + votable.class.to_s.tableize.gsub("_", " ") + "."
      # In case different logic is needed for each:
      #case votable.class
      #when Solution.class
      #  "You cannot vote for your own solutions."
      #when Comment.class
      #  "You cannot vote for your own comments."
      #end
    end
  end

end
