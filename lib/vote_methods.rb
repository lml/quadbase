# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

module VoteMethods
  
  def up_votes
    votes.where{thumbs_up == true}
  end
  
  def down_votes
    votes.where{thumbs_up == false}
  end
  
  def combined_vote_count
    up_votes.count - down_votes.count
  end
  
end
