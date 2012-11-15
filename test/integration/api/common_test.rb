require 'integration/api/integration_test'

class Api::CommonTest < Api::IntegrationTest
  
  setup do
    @oauth_application = FactoryGirl.create(:oauth_application)
  end

  test "tokens never expire" do
    user = FactoryGirl.create(:user, :password => 'password')
    token = oauth_token_wrapper(@oauth_application, user.email, "password")
    assert_nil token.oauth_token.expires_at
    Timecop.travel(Time.local(2999,1,1,1,0,0))
    assert !token.oauth_token.expired?
    Timecop.return
  end

end


