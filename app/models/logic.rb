require 'erb'

class Logic < ActiveRecord::Base
  belongs_to :logicable, :polymorphic => true
  
  validate :variable_parse_succeeds
  validate :code_runs_safely

  before_save :cache_code
  
  serialize :variables_array
  
  attr_reader :results
  
  JS_RESERVED_WORDS_REGEX = /^(do|if|in|for|let|new|try|var|case|else|enum|eval|
                               false|null|this|true|void|with|break|catch|class|
                               const|super|throw|while|yield|delete|export|
                               import|public|return|static|switch|typeof|
                               default|extends|finally|package|private|continue|
                               debugger|function|arguments|interface|protected|
                               implements|instanceof)$/
                               
  VARIABLE_REGEX = /^[_a-zA-Z]{1}\w*$/
  
  def run(seed = rand(2e9))
    context = SaferJS.compile(get_cached_code)
    @results = context.call('wrapper.runCode') # TODO is here the place to pass in values from prior logic?
    
    return @results
  end
  
protected

  def code_runs_safely
  end
  
  def get_cached_code
    cached_code ||= cache_code
  end
  
  def cache_code
    erb_code = ERB.new <<-CODE
      var wrapper = {
        runCode: function() {
          <%= code %>
          results = {};
          <% variables_array.each do |variable| %>
            results['<%= variable %>'] = <%= variable %>
          <% end %>
          return results;                  
        }
      }
    CODE

    self.cached_code = erb_code.result(binding)
  end
  
  def variable_parse_succeeds
    
    self.variables_array = variables.split(/[\s,]+/)
    
    if !self.variables_array.all?{|v| VARIABLE_REGEX =~ v}    
      errors.add(:variables, "can only contain letter, numbers and 
                              underscores.  Additionally, the first character 
                              must be a letter or an underscore.")
    end

    reserved_vars = self.variables_array.collect do |v| 
      match = JS_RESERVED_WORDS_REGEX.match(v)
      match.nil? ? nil : match[0]
    end
    
    reserved_vars.compact!
    
    reserved_vars.each do |v|
      errors.add(:variables, "cannot contain the reserved word '#{v}'.")
    end

    if !self.variables_array.all?{|v| JS_RESERVED_WORDS_REGEX =~ v}
      errors.add(:variables, "")
    end

    self.variables = self.variables_array.join(", ")

    errors.any?
  end
  
end
