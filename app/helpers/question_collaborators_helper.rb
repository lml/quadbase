# Copyright (c) 2011 Rice University.  All rights reserved.

module QuestionCollaboratorsHelper
  def collaborator_names(collaborators)
    collaborators.empty? ? '[not specified]' : collaborators.collect{|c| link_to c.user.full_name, c.user}.join(', ').html_safe
  end
  
  def requestable_role_status(collaborator, role_symbol, can_create_role_requests)
    has_role = collaborator.has_role?(role_symbol)
    request = collaborator.get_request(role_symbol)
    has_request = !request.nil?

    output = tf_to_yn(has_role)
    
    output << "<div class='role_change_request'>"
    
    if has_request
      output << render(:partial => 'question_collaborators/pending', 
                       :locals => {:question_role_request_id => request.id})
    elsif can_create_role_requests
      request_html_id = "req_#{collaborator.id}_#{role_symbol.to_s}"
      
      output << content_tag(:div, :id=>"#{request_html_id}") do
                  
                  render(:partial => 'question_collaborators/request_role', 
                         :locals => {:question_collaborator_id => collaborator.id, 
                                     :role => role_symbol })
      end 
    end  
    
    output << "</div>"  
    
    output.html_safe
  end

  def has_roles(collaborator)
    collaborator.has_role?(:any)
  end
  
end
