# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

module VariatedContentHtml
  attr_writer :variated_content_html

  def variated_content_html
    @variated_content_html || self.content_html
  end
end
