# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'rack/utils'
 
class FlashSessionCookieMiddleware
  def initialize(app, session_key = '_session_id')
    @app = app
    @session_key = session_key
  end
 
  def call(env)
    if env['HTTP_USER_AGENT'] =~ /^(Adobe|Shockwave) Flash/
      req = Rack::Request.new(env)
      env['HTTP_COOKIE'] = [ @session_key,
                             req.params[@session_key] ].join('=').freeze unless req.params[@session_key].nil?
      env['HTTP_ACCEPT'] = "#{req.params['_http_accept']}".freeze unless req.params['_http_accept'].nil?
    end
 
    @app.call(env)
  end
end