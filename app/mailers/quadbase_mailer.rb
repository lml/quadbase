# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class QuadbaseMailer < ActionMailer::Base
  default :from => "noreply@quadbase.org"

  def mail(headers={}, &block)
    headers[:subject] = "[Quadbase] " + headers[:subject]
    super(headers, &block)
  end
end
