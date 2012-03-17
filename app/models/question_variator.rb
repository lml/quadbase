
# Responsible for managing the different variations that you can get from one 
# question given things like random seeds, logic, part re-ordering, etc.
class QuestionVariator
  attr_reader :seed
  
  def initialize(seed = random(2e9))
    @seed = seed
  end
  
  def run(logic)
    return if logic.nil?
    
    @output ||= Logic::Output.new 
    @output = logic.run(@seed, @output)
  end
  
  def fill_in_variables(text)
    return nil if text.nil?
    text.gsub(/\=([_a-zA-Z]{1}\w*)\=/u) {|match| @output.variables[match[1]] }
  end
  
end