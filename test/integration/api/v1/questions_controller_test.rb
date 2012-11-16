require 'integration/api/integration_test'

class Api::V1::QuestionsControllerTest < Api::IntegrationTest
  
  setup do
    @published_question = make_simple_question(:method => :create, :published => true)
    @unpublished_question = make_simple_question(:method => :create)
    @oauth_application = FactoryGirl.create(:oauth_application)
    
    @unpublished_question_user = @unpublished_question.question_collaborators.first.user
    @unpublished_question_user.update_attribute(:password, "password")
    
    @published_question_user = @published_question.question_collaborators.first.user
    @published_question_user.update_attribute(:password, "password")
  end

  test "should be able to access published question without credentials" do
    response = api_call :get, "/api/questions/#{@published_question.to_param}", "v1"
    assert_response :success
    json = JSON.parse(@response.body)
    # lame test that the api is working; ponder switch to rspec and https://github.com/collectiveidea/json_spec
    assert json.has_key?("simple_question") 
  end

  test "should get published question using non author oauth credentials" do
    token = oauth_token_wrapper(@oauth_application, @unpublished_question_user.email, "password")
    response = token.get("/api/questions/#{@published_question.to_param}", "v1")
    assert_equal 200, response.status
  end

  test "should not be able to access unpublished question without credentials" do
    api_call :get, "/api/questions/#{@unpublished_question.to_param}", "v1"
    assert_response :forbidden
  end

  test "should get unpublished question using oauth credentials" do
    token = oauth_token_wrapper(@oauth_application, @unpublished_question_user.email, "password")
    response = token.get("/api/questions/#{@unpublished_question.to_param}", "v1")
    assert_equal 200, response.status
  end

  test "should not get unpublished question using wrong oauth credentials" do
    token = oauth_token_wrapper(@oauth_application, @published_question_user.email, "password")
    assert_oauth_error (403) {
      token.get("/api/questions/#{@unpublished_question.to_param}", "v1")
    }
  end

end


