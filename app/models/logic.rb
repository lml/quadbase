# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'erb'
require 'json'

class Logic < ActiveRecord::Base
  belongs_to :logicable, :polymorphic => true
  
  after_initialize :initialize_required_version_ids
  before_validation :cleanup_required_version_ids
  
  validate :variable_parse_succeeds
  validate :code_compiles
  validate :logic_library_versions_valid
  validate :validate_change_allowed

  after_validation :cache_code
  
  serialize :variables_array
  serialize :required_logic_library_version_ids

  attr_accessible :variables, :code, :required_logic_library_version_ids
  
  JS_RESERVED_WORDS_REGEX = /^(do|if|in|for|let|new|try|var|case|else|enum|eval|
                               false|null|this|true|void|with|break|catch|class|
                               const|super|throw|while|yield|delete|export|
                               import|public|return|static|switch|typeof|
                               default|extends|finally|package|private|continue|
                               debugger|function|arguments|interface|protected|
                               implements|instanceof)$/
                               
  OTHER_RESERVED_WORDS_REGEX = /^(seedrandom)$/
                               
  VARIABLE_REGEX = /^[_a-zA-Z]{1}\w*$/
  
  def run(options = {})
    options[:seed] ||= rand(2e9)
    options[:prior_output] ||= Output.new
    options[:library_version_ids] ||= required_logic_library_version_ids

    if !code.blank?
      variable_parse_succeeds if variables_array.nil? 
      results = Bullring.run(readied_script(options[:seed],options[:prior_output]),
                             {'library_names' => options[:library_version_ids]})
  
      options[:prior_output].store!(results)
    else
      options[:prior_output]
    end
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
  
  def content_copy
    Logic.new(:code => code, :variables => variables, :cached_code => cached_code, 
              :variables_array => variables_array, 
              :required_logic_library_version_ids => required_logic_library_version_ids)
  end
  
protected

  def code_compiles
    code_errors = Bullring.check(code)
    code_errors.each do |code_error|
      next if code_error.nil?
      if !(code_error['reason'].to_s =~ /^Stopping/)
        errors.add(:base, "#{code_error['reason']}, line #{code_error['line']}, character #{code_error['character']}")      
      end
    end
    errors.empty?
  end

  def readied_script(seed, prior_output)
    get_cached_code + ";" + "wrapper.runCode(#{seed},#{prior_output.variables.to_json})"
  end
  
  def get_cached_code
    self.cached_code || cache_code
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
      match = JS_RESERVED_WORDS_REGEX.match(v) || OTHER_RESERVED_WORDS_REGEX.match(v)
      match.nil? ? nil : match[0]
    end
    
    reserved_vars.compact!
    
    reserved_vars.each do |v|
      errors.add(:variables, "cannot contain the reserved word '#{v}'.")
    end

    self.variables = self.variables_array.join(", ")

    errors.none?
  end
  
  def logic_library_versions_valid
    included_library_versions = LogicLibraryVersion.where{id.in(my{required_logic_library_version_ids})}
    
    if included_library_versions.count != required_logic_library_version_ids.size
      errors.add(:base, "You have specified libraries that do not exist")
    end

    # Make sure that the included library versions cover the required libraries
    
    always_required_libraries = LogicLibrary.where{always_required == true}
    included_libraries = included_library_versions.collect{|version| version.logic_library}

    if (included_libraries & always_required_libraries).length < always_required_libraries.length
      errors.add(:base, "The specified libraries do not include all required libraries")
    end
    
    errors.none?
  end
  
  def initialize_required_version_ids
    self.required_logic_library_version_ids ||= LogicLibrary.latest_required_versions(false).collect{|v| v.id.to_s}
  end
  
  # The required version ids array might have an empty string in it (because of the
  # way that HTML handles unchecked checkboxes in forms).  Strip those out.
  def cleanup_required_version_ids
    # self.required_logic_library_version_ids ||= []
    self.required_logic_library_version_ids.reject!{|id| id.blank?}
  end
  
  def change_allowed?
    logicable.nil? || logicable.content_change_allowed?
  end
  
  def validate_change_allowed
    return if change_allowed?
    errors.add(:base, "This logic cannot be changed.")
    errors.any?
  end
  
end
