# Copyright (c) 2011 Rice University.  All rights reserved.

module QuestionRoleRequestsHelper
  def request_type(role_request)
    if role_request.toggle_is_author
      return "Author" +
             (role_request.question_collaborator.is_author ? " (Drop)" : " (Add)")
    end

    if role_request.toggle_is_copyright_holder
      return "Copyright" +
             (role_request.question_collaborator.is_copyright_holder ? " (Drop)" : " (Add)")
    end
  end
end
