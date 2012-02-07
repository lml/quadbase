# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

Recaptcha.configure do |config|
  config.public_key  = SECRET_SETTINGS[:recaptcha_public_key]
  config.private_key = SECRET_SETTINGS[:recaptcha_private_key]
end
