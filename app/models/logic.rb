# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'erb'
require 'json'

class Logic < ActiveRecord::Base
  belongs_to :logicable, :polymorphic => true
  
  validate :variable_parse_succeeds
  validate :code_compiles
  validate :code_runs_safely
  validate :logic_library_versions_valid

  before_save :cache_code
  
  serialize :variables_array
  serialize :required_logic_library_version_ids
  
  JS_RESERVED_WORDS_REGEX = /^(do|if|in|for|let|new|try|var|case|else|enum|eval|
                               false|null|this|true|void|with|break|catch|class|
                               const|super|throw|while|yield|delete|export|
                               import|public|return|static|switch|typeof|
                               default|extends|finally|package|private|continue|
                               debugger|function|arguments|interface|protected|
                               implements|instanceof)$/
                               
  OTHER_RESERVED_WORDS_REGEX = /^(seedrandom)$/
                               
  VARIABLE_REGEX = /^[_a-zA-Z]{1}\w*$/
  
  
  # Minified version of seedrandom.js version 2.0. by David Bau 4/2/2011, BSD license  
  RANDOM_CODE = <<-CODE
    (function(j,i,g,m,k,n,o){function q(b){var e,f,a=this,c=b.length,d=0,h=a.i=a.j=a.m=0;
      a.S=[];a.c=[];for(c||(b=[c++]);d<g;)a.S[d]=d++;for(d=0;d<g;d++)e=a.S[d],
      h=h+e+b[d%c]&g-1,f=a.S[h],a.S[d]=f,a.S[h]=e;a.g=function(b){var c=a.S,d=a.i+1&g-1,
      e=c[d],f=a.j+e&g-1,h=c[f];c[d]=h;c[f]=e;for(var i=c[e+h&g-1];--b;)d=d+1&g-1,e=c[d],
      f=f+e&g-1,h=c[f],c[d]=h,c[f]=e,i=i*g+c[e+h&g-1];a.i=d;a.j=f;return i};a.g(g)}
      function p(b,e,f,a,c){f=[];c=typeof b;if(e&&c=="object")for(a in b)if(a.indexOf("S")<5)
      try{f.push(p(b[a],e-1))}catch(d){}return f.length?f:b+(c!="string"?"\\0":"")}
      function l(b,e,f,a){b+="";for(a=f=0;a<b.length;a++){var c=e,d=a&g-1,h=(f^=e[a&g-1]*19)+
      b.charCodeAt(a);c[d]=h&g-1}b="";for(a in e)b+=String.fromCharCode(e[a]);return b}
      i.seedrandom=function(b,e){var f=[],a;b=l(p(e?[b,j]:arguments.length?b:[(new Date).getTime(),
      j,window],3),f);a=new q(f);l(a.S,j);i.random=function(){for(var c=a.g(m),d=o,b=0;c<k;)
      c=(c+b)*g,d*=g,b=a.g(1);for(;c>=n;)c/=2,d/=2,b>>>=1;return(c+b)/d};return b};o=i.pow(g,m);
      k=i.pow(2,k);n=k*2;l(i.random(),j)})([],Math,256,6,52);  
  CODE
    
  def run(options = {})
    options[:seed] ||= rand(2e9)
    options[:prior_output] ||= Output.new
    
    variable_parse_succeeds if variables_array.nil? 

    results = Bullring.run(readied_script(options[:seed],options[:prior_output]),
                           {'library_names' => required_logic_library_version_ids})

    options[:prior_output].store!(results)
  end
    
  class Output
    attr_reader :variables, :console
    
    def initialize()
      @variables = {}
      @console = []
    end
    
    def store!(results_hash)
      @variables = results_hash["result"]
      @console.push(results_hash["console"])
      self
    end
  end
  
  def empty?
    code.blank?
  end
  
protected

  def code_compiles
    code_errors = Bullring.check(code)
    code_errors.each do |code_error|
      errors.add(:base, "#{code_error['reason']}, line #{code_error['line']}, character #{code_error['character']}")      
    end
    errors.empty?
  end

  def code_runs_safely
    # TODO this might go into question so can get the appropriate prior output values
    # TODO make sure that the question content is the same from run to run with the same seed
  end
  
  def readied_script(seed, prior_output)
    get_cached_code + ";" + "wrapper.runCode(#{seed},#{prior_output.variables.to_json})"
  end
  
  def get_cached_code
    cached_code ||= cache_code
  end
  
  def cache_code
    erb_code = ERB.new <<-CODE
      
      var wrapper = {
        runCode: function(seed,args) {
          
          // Load the passed in variables (in args) into this scope
          
          for (arg in args) {
            eval(arg + ' = ' + args[arg]);  
          }
          
          // Initialize the random number generator with the specified seed
          
          Math.seedrandom(seed);
          
          // Exectue the logic's code block
          
          <%= code %>
          
          // Build up the results object/hash.  Load each of this logic's
          // variables into the results.  Then load all of the incoming 
          // args into the results so they are also available to users of this
          // logic (do it last to guarantee the user isn't changing the incoming 
          // value)
          
          results = {};
          
          <% variables_array.each do |variable| %>
            results['<%= variable %>'] = <%= variable %>
          <% end %>
          
          for (arg in args) {
            results[arg] =args[arg];  
          }
          
          return {result: results};                  
        }
      }
    CODE

    self.cached_code = RANDOM_CODE + "\n\n" + erb_code.result(binding)
  end
  
  def variable_parse_succeeds
    
    self.variables_array = variables.split(/[\s,]+/)
    
    if !self.variables_array.all?{|v| VARIABLE_REGEX =~ v}    
      errors.add(:variables, "can only contain letter, numbers and 
                              underscores.  Additionally, the first character 
                              must be a letter or an underscore.")
    end

    reserved_vars = self.variables_array.collect do |v| 
      match = JS_RESERVED_WORDS_REGEX.match(v) || OTHER_RESERVED_WORDS_REGEX.match(v)
      match.nil? ? nil : match[0]
    end
    
    reserved_vars.compact!
    
    reserved_vars.each do |v|
      errors.add(:variables, "cannot contain the reserved word '#{v}'.")
    end

    self.variables = self.variables_array.join(", ")

    errors.any?
  end
  
  def logic_library_versions_valid
    always_required_version_ids = LogicLibrary.latest_required_versions(false).collect{|v| v.id}
    
    if LogicLibraryVersion.where(:id => required_logic_library_version_ids).count != required_logic_library_version_ids.size
      errors.add(:base, "You have specified libraries that do not exist")
    end

    if always_required_version_ids.any?{|always| !required_logic_library_version_ids.include?(always.to_s)}        
      errors.add(:base, "The specified libraries do not include all required libraries")
    end
  end
  
end
