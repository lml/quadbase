# We originally had some methods in the ApplicationController that were shared
# with views using helper_method.  However, when we added some isolate engines
# (e.g. Doorkeeper), they were not able to access these methods from the views
# (from the layouts).  So we put them here and explicitly include then in both
# the ApplicationController and ApplicationHelper

module SharedApplicationMethods

  def user_is_admin?
    user_signed_in? && current_user.is_administrator?
  end

end