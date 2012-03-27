
# Responsible for managing the different variations that you can get from one 
# question given things like random seeds, logic, part re-ordering, etc.
class QuestionVariator
  attr_reader :seed
  
  def initialize(seed = rand(2e9))
    @seed = seed
    @output ||= Logic::Output.new 
  end
  
  def run(logic)
    return if logic.nil?
    
    @output = logic.run({:seed => @seed, :prior_output => @output})
  end
  
  def fill_in_variables(text)
    return nil if text.nil?
    text.gsub(/\=([_a-zA-Z]{1}\w*)=/u) {|match| @output.variables[$1] || "<span class='undefined_variable' title='This variable is undefined!'>#{$1}</span>"}
  end
  
end