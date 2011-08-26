# Copyright (c) 2011 Rice University.  All rights reserved.

class QuadbaseMailer < ActionMailer::Base
  default :from => "noreply@quadbase.org"

  def mail(headers={}, &block)
    headers[:subject] = "[Quadbase] " + headers[:subject]
    super(headers, &block)
  end
end
