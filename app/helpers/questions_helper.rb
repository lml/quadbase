# Copyright (c) 2011 Rice University.  All rights reserved.

module QuestionsHelper
  
  def variant_for_question(question)
    case question.question_type
    when "SimpleQuestion"
      "simple"
    when "MatchingQuestion"
      "matching"
    when "MultistepQuestion"
      "multistep"
    when "MultipartQuestion"
      "multipart"
    end
  end
  
  def view_dir(question)
    question.question_type.underscore.pluralize
  end
  
  def question_type_abbreviation(question)
    case question.question_type
    when "SimpleQuestion"
      !question.answer_choices.empty? ? "Choice" : "Free-form"
    when "MatchingQuestion"
      "Matching"
    when "MultistepQuestion"
      "Multi-step"
    when "MultipartQuestion"
      "Multi-part"
    end    
  end

  # question_id_text and questions_id_text in application helper
  
  def question_id_text_no_version(question)
    "q#{question.number}"
  end
  
  def question_id_link(question)
    link_to(question_id_text(question), question_path(question))
  end

  def question_id_links(questions)
    questions.collect { |q| question_id_link(q) }.join(", ").html_safe
  end

  def confirm_drop_roles(questions)
    output = ''
    if questions.detect {|q| !q.roleless_collaborators.blank?}
      output << 'return confirm("The following users are listed as collaborators with no roles and will be dropped from the list of collaborators if you choose to continue:\n\n'
      questions.each { |q| q.roleless_collaborators.each { |rc|
                       output << rc.user.full_name << '\n' } }
      output << '\nAre you sure you want to continue and drop these collaborators?");'
    end
    output
  end
  
  def example_problem(param)
    output = '<div class="exampleQuestion">'
    output << '<div class="questionBox quad-question" style="font-size:16px">'
           
    if Question.exists?(param)
      output << render(:partial => "questions/show", 
                       :locals => {:question => Question.from_param(param) })
    else
      output << "Example coming soon!"
    end

    output << '</div>'
    output << '</div>'
    output.html_safe
  end
  
end
