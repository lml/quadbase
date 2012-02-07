# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

module CommentsHelper
  def modified_string(comment)
    (comment.is_modified? ? "Last modified on " : "Posted on ") +
    comment.updated_at.strftime('%b %d %Y, %I:%M %p')
  end
end
