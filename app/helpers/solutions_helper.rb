# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

module SolutionsHelper
  def modified_string(solution)
    #(solution.is_modified? ? "Last modified on " : "Created on ") +
    solution.updated_at.strftime('%b %d %Y, %I:%M %p')
  end
end
