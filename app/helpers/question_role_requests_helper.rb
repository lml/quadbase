# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

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
