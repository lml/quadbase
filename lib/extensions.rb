# Copyright (c) 2011 Rice University.  All rights reserved.

class SecurityTransgression < StandardError; end

class AbstractMethodCalled < StandardError; end

class NotYetImplemented < StandardError; end

class IllegalArgument < StandardError; end

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

