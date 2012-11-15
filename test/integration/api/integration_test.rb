require 'test_helper'
require 'json'

# References:
#  http://twobitlabs.com/2010/09/setting-request-headers-in-rails-functional-tests/

class Api::IntegrationTest < ActionDispatch::IntegrationTest

  class TokenWrapper
    attr_reader :oauth_token

    def initialize(oauth_token)
      @oauth_token = oauth_token
    end

    def get(url, api_version, params={})
      @oauth_token.get(url, {:headers => {'Accept' => "application/vnd.quadbase.#{api_version}"}})
    end
  end

  def oauth_token_wrapper(application, email, password)
    client = OAuth2::Client.new(application.uid, application.secret) do |b|
      b.request :url_encoded
      b.adapter :rack, Rails.application
    end
    TokenWrapper.new(client.password.get_token(email, password))
  end

  def api_call(method, url, api_version, params={})
    case method
    when :get
      get(url, params, {'Accept' => "application/vnd.quadbase.#{api_version}"})
    end
  end

  def assert_oauth_error(expected_status, msg=nil)
    got_oauth_error = false
    oauth_error_status = expected_status

    begin
      yield
    rescue OAuth2::Error => e
      got_oauth_error = true
      oauth_error_status = e.response.status
    end

    if !got_oauth_error
      flunk(build_message(msg, "Expression did not produce an oauth error as expected"))
    elsif oauth_error_status != expected_status
      flunk(build_message(msg, "Expression expected to produce an oauth error with status ? but had status ?", expected_status, oauth_error_status))
    end
  end

end


