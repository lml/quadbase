# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'net/http'

class SecurityTransgression < StandardError; end

class AbstractMethodCalled < StandardError; end

class NotYetImplemented < StandardError; end

class IllegalArgument < StandardError; end

class IllegalState < StandardError; end

def url_responds?(url)
  begin # check header response
    case Net::HTTP.get_response(URI.parse(url))
      when Net::HTTPSuccess, Net::HTTPMovedPermanently, Net::HTTPMovedTemporarily then true
      else false
    end
  rescue # Recover on DNS failures..
    false
  end
end

def online?
  url_responds?("http://www.google.com")
end

def to_bool(string)
  return true if string== true || string =~ (/(true|t|yes|y|1)$/i)
  return false if string== false || string.nil? || string =~ (/(false|f|no|n|0)$/i)
  raise ArgumentError.new("invalid value for Boolean: \"#{string}\"")
end

module ActiveRecord
  class Base
    def better_becomes(klass)
      became = self.becomes(klass)
      became.instance_variable_set("@errors", @errors)
      became    
    end  
    
    # If you're in the console and say myModel.method('id').call(), you get back
    # the id attribute of the instance you have.  But for some reason that gives
    # an 'undefined method' error when run in a view.  So this method just checks
    # to see if the thing being called is an attribute, and if so calls a method
    # to read that attribute; otherwise, calls it as a method.
    def call(method_or_attribute)
      self.attribute_present?(method_or_attribute) ? 
        self.read_attribute(method_or_attribute) :
        self.method(method_or_attribute).call()
    end

    def self.find_in_specified_order(ids)
      items = find(ids)

      order_hash = {}
      ids.each_with_index {|id, index| order_hash[id.to_i]=index}

      items.sort_by!{|item| order_hash[item.id]}
    end
  end
end

class Object
  
  # deep_clone implementation from:
  # http://d.hatena.ne.jp/pegacorn/20070412/1176309956
  def deep_clone
    return @deep_cloning_obj if @deep_cloning
    
    @deep_cloning_obj = clone
    @deep_cloning_obj.instance_variables.each do |var|
      val = @deep_cloning_obj.instance_variable_get(var)
      
      begin
	      @deep_cloning = true
	      val = val.deep_clone
      rescue TypeError
	      next
      ensure
	      @deep_cloning = false
      end
      
      @deep_cloning_obj.instance_variable_set(var, val)
    end
    deep_cloning_obj = @deep_cloning_obj
    @deep_cloning_obj = nil
    deep_cloning_obj
  end
end

