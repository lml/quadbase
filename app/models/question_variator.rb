# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

# Responsible for managing the different variations that you can get from one 
# question given things like random seeds, logic, part re-ordering, etc.
class QuestionVariator
  attr_reader :seed
  attr_reader :output_hash
  
  def initialize(seed=nil, watch_output=false)
    @seed = seed || rand(2e9)
    @output ||= Logic::Output.new 
    @watch_output = watch_output
  end
  
  def run(logic)
    return if logic.nil?
    
    # Run the logic, optionally, computing and storing a hash of the output
    @output = logic.run({:seed => @seed, :prior_output => @output}).tap do |output|
      @output_hash = (@output_hash || 0) + output.variables.inspect.hash if @watch_output
    end
  end
  
  def fill_in_variables(text)
    return nil if text.nil?
    text.gsub(/\=([_a-zA-Z]{1}\w*)(%[^=]*)?=/u) { |match| 
      var = @output.variables[$1]
      
      begin
        ($2.blank? ? var : $2 % var) || 
        "<span class='undefined_variable' title='This variable is undefined!'>#{$1}</span>"
      rescue ArgumentError => e
        raise BadFormatStringError, e.message, caller
      end
    }
  end
  
end

class BadFormatStringError < StandardError; end