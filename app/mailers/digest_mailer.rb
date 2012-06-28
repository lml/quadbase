# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class DigestMailer < ActionMailer::Base
  default :from => "noreply@quadbase.org"

  def mail(headers={}, block={})
    headers[:subject] = "[Quadbase] " + headers[:subject]
    block[:message] = block[:message]
    super(headers, block)
  end
end
