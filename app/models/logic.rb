require 'erb'

class Logic < ActiveRecord::Base
  belongs_to :logicable, :polymorphic => true
  
  
  validate :code_runs_safely

  before_save :cache_code
  
  attr_reader :results
  
  def run


    # TODO on save variables, split into array (serialized in class)
    # TODO cache this code


    # wrapped_code = ERB.new <<-CODE
    #   var wrapper = {
    #     runCode: function() {
    #       <%= code %>
    #       test = "hi";
    #       results = {};
    #       <% variables.each do |variable| %>
    #         results['<%= variable %>'] = <%= variable %>
    #       <% end %>
    #       return results;                  
    #     }
    #   }
    # CODE
    # 
    # 
    # 
    # ready_code = wrapped_code.result(binding)
    # # logger.debug(ready_code)
    # 
    # debugger
    
    c = SaferJS.compile(get_cached_code)
    
    @results = c.call('wrapper.runCode') # TODO is here the place to pass in values from prior logic?
    
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
          <% variables.each do |variable| %>
            results['<%= variable %>'] = <%= variable %>
          <% end %>
          return results;                  
        }
      }
    CODE

    self.cached_code = erb_code.result(binding)
  end
end
