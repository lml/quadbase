# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'singleton'

class AnonymousUser
  include Singleton
  
  # These are the same as the ones in User, which is why the pivotal labs guys use inheritance...
  def can_read?(resource)
    resource.can_be_read_by?(self)
  end
  
  def can_create?(resource)
    #resource.can_be_created_by?(self)
    false
  end
  
  def can_update?(resource)
    #resource.can_be_updated_by?(self)
    false
  end
    
  def can_destroy?(resource)
    #resource.can_be_destroyed_by?(self)
    false
  end

  def can_vote_on?(resource)
    #resource.can_be_voted_on_by?(self)
    false
  end

  def can_join?(container_type, container_id)
    #case container_type
    #when 'question'
    #  return Question.find(container_id).can_be_joined_by?(self)
    #when 'list'
    #  return List.find(container_id).can_be_joined_by?(self)
    #end
    false
  end
  
  def can_tag?(resource)
    #resource.can_be_tagged_by?(self)
    false
  end
  
  def is_anonymous?
    true
  end

  def is_disabled?
    false
  end

  def is_administrator?
    false
  end

  # Necessary if an anonymous user ever runs into an Exception
  # or else the developer email doesn't work
  def username
    'Anonymous'
  end
    
  # Just so we can never get mixed up with this and an active record
  def id
    nil
  end
  
end
