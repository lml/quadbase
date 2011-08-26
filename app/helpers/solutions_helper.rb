# Copyright (c) 2011 Rice University.  All rights reserved.

module SolutionsHelper
  def modified_string(solution)
    #(solution.is_modified? ? "Last modified on " : "Created on ") +
    solution.updated_at.strftime('%b %d %Y, %I:%M %p')
  end
end
