# Copyright (c) 2011 Rice University.  All rights reserved.

module VoteMethods
  
  def up_votes
    votes.where(:thumbs_up => true)
  end
  
  def down_votes
    votes.where(:thumbs_up => false)
  end
  
  def combined_vote_count
    up_votes.count - down_votes.count
  end
  
end