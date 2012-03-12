class Logic < ActiveRecord::Base
  belongs_to :logicable, :polymorphic => true
  
  validate :code_runs_safely
  
  def run

    # Force the ExecJS runtime to be Node (so that we can use the Sandbox module)
    debugger
    # ExecJS.runtime = ExecJS::Runtimes::Node
    #  c = ExecJS.compile(nodejs_code(nil))
    #     c.call('wrapper','')

    c = SaferJS.compile(nodejs_code(nil))
    c.call('wrapper','')
       
    # SaferJS.eval(nodejs_code(nil))
       
    # c = ExecJS.eval(nodejs_code(nil))
    # c = ExecJS.compile("function hi() {return 2;}")
    
    # c.eval("window.b = 3")
    # c.eval("window") #=> {"a"=>5, "b"=>2}


    # results = {};
    # 
    # for (ii = 0; ii < variables.length; ii++) {
    #   results[variables[ii]] = eval(variables[ii] + ".toString();");
    # }
    # return results;
    
  end
  
  def nodejs_code(input)

    if false
      # //        var Sandbox = require('sandbox');
      # //        var sb = new Sandbox();
      # //
      # //        result = sb.run( "(function(name) { function temp() {return 'bob';} return 'Hi there, ' + temp() + name + '!' + Math.cos(0); })('Fabio')", function( output ) {
      # //        console.log( "Example 2: " + output.result + "\n" )
      # //          return result;
      
    end
    
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
