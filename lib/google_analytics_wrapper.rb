class GoogleAnalyticsWrapper
  
  def initialize(cookies = nil)
    if Rails.env.production?
      @gabba = Gabba::Gabba.new("UA-23761609-3", "quadbase.org")
      @gabba.identify_user(cookies[:__utma]) if !cookies.nil?
    end
  end
  
  def method_missing(m, *args, &block)  
    if Rails.env.production?
      @gabba.send(m, *args, &block)
    end
  end
  
end
