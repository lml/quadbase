# Copyright (c) 2011 Rice University.  All rights reserved.

ActiveRecord::Base.class_eval do
  def self.validates_as_url(attr_name, options={})
    validates attr_name, 
              :presence => true, 
              :uri => { :format => /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix }
  end
end