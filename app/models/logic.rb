require 'erb'

class Logic < ActiveRecord::Base
  belongs_to :logicable, :polymorphic => true
  
  validate :code_runs_safely
  
  def run


    # TODO on save variables, split into array (serialized in class)
    # TODO cache this code


    wrapped_code = ERB.new <<-CODE
      var wrapper = {
        runCode: function() {
          <%= code %>
          test = "hi";
          results = {};
          <% variables.each do |variable| %>
            results['<%= variable %>'] = <%= variable %>
          <% end %>
          return results;                  
        }
      }
    CODE



    ready_code = wrapped_code.result(binding)
    logger.debug(ready_code)
    
    debugger
    
    c = SaferJS.compile(ready_code)
    ruby_results = c.call('wrapper.runCode')      # TODO is here the place to pass in values from prior logic?
    
    
    
    
  end
  
  def nodejs_code(input)

  
    
    <<-CODE
      function wrapper() {
        //Sandbox = require('sandbox');
        //var x = require('sandbox');
        console.log('hi');
        console.log('there');
        return {x: 2};
      }
    CODE
    

  end
  
protected

  def code_runs_safely
  end
end
