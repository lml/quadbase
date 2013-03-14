class GoogleAnalyticsWrapper
  
  def initialize(cookies, request)
    if Rails.env.production?
      @gabba = Gabba::Gabba.new("UA-23761609-3", "quadbase.org", request.env['HTTP_USER_AGENT'])
      @gabba.ip(request.env["REMOTE_ADDR"])
      @gabba.identify_user(cookies[:__utma]) if !cookies.nil?
    end
  end
  
  def method_missing(m, *args, &block)  
    if Rails.env.production?
      @gabba.send(m, *args, &block)
    end
  end
  
end