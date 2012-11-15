require 'test_helper'

class Api::V1::QuestionsControllerTest < ActionController::TestCase

  setup do
    @published_question = make_simple_question(:method => :create, :published => true)
    @unpublished_question = make_simple_question(:method => :create)
    @oauth_application = FactoryGirl.create(:oauth_application)
  end

  def oauth_token(email, password)
    client = OAuth2::Client.new(app.uid, app.secret) do |b|
      b.request :url_encoded
      b.adapter :rack, Rails.application
    end
    client.password.get_token(email, password)
  end


  def http_get(url, params={}, header_fields={})
    Rails.logger.debug("http post url: #{url}, params: #{params.inspect}")
      uri = URI(url)
      req = Net::HTTP::Get.new(uri.path)
      req.set_form_data(params)
      header_fields.each do |key, value|
        req.add_field key, value
      end

      res = Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request(req)
      end

      # case res
      # when Net::HTTPSuccess, Net::HTTPRedirection
      #   res
      # else
      #   res.value
      # end
      
    end

  test "should be able to access published question without credentials" do
    @request.env["Accept"] = 'application/vnd.quadbase.v1'
    get("/api/questions/#{@published_question.to_param}")
    asssert_response :success

    # oauth_token()
    # Rails.logger.debug(http_get("http://localhost:3000/api/questions/#{@published_question.to_param}", {}, {'Accept' => 'application/vnd.quadbase.v1'}))
  end

  # test "should not get index not logged in" do
  #   get :index, :question_id => @question.to_param
  #   assert_redirected_to login_path
  # end

  # test "should not get index not authorized" do
  #   user_login
  #   get :index, :question_id => @question.to_param
  #   assert_response(403)
  # end

  # test "should get index" do
  #   sign_in @user
  #   get :index, :question_id => @question.to_param
  #   assert_response :success
  # end

  # test "should get index published question" do
  #   user_login
  #   get :index, :question_id => @published_question.to_param
  #   assert_response :success
  # end

  # test "should not get new not logged in" do
  #   get :new, :question_id => @question.to_param
  #   assert_redirected_to login_path
  # end

  # test "should not get new not authorized" do
  #   user_login
  #   get :new, :question_id => @question.to_param
  #   assert_response(403)
  # end

  # test "should get new" do
  #   sign_in @user
  #   get :new, :question_id => @question.to_param
  #   assert_response :success
  #   assert_not_nil assigns(:comments)
  # end

  # test "should get new published question" do
  #   user_login
  #   get :new, :question_id => @published_question.to_param
  #   assert_response :success
  #   assert_not_nil assigns(:comments)
  # end

  # test "should not create comment not logged in" do
  #   assert_difference('Comment.count', 0) do
  #     post :create, :question_id => @question.to_param, :comment => @comment.attributes
  #   end

  #   assert_redirected_to login_path
  # end

  # test "should not create comment not authorized" do
  #   user_login
  #   assert_difference('Comment.count', 0) do
  #     post :create, :question_id => @question.to_param, :comment => @comment.attributes
  #   end

  #   assert_response(403)
  # end

  # test "should create comment" do
  #   sign_in @user
  #   assert_difference('Comment.count') do
  #     post :create, :question_id => @question.to_param, :comment => @comment.attributes
  #   end

  #   assert_redirected_to question_comments_path(@question.to_param)
  # end

  # test "should create comment published question" do
  #   user_login
  #   assert_difference('Comment.count') do
  #     post :create, :question_id => @published_question.to_param, :comment => @comment.attributes
  #   end

  #   assert_redirected_to question_comments_path(@published_question.to_param)
  # end

  # test "should not show comment not logged in" do
  #   get :show, :id => @comment.to_param
  #   assert_redirected_to login_path
  # end

  # test "should not show comment not authorized" do
  #   user_login
  #   get :show, :id => @comment.to_param
  #   assert_response(403)
  # end

  # test "should show comment" do
  #   sign_in @user
  #   get :show, :id => @comment.to_param
  #   assert_response :success
  # end

  # test "should show comment published question" do
  #   user_login
  #   get :show, :id => @published_comment.to_param
  #   assert_response :success
  # end

  # test "should not get edit not logged in" do
  #   get :edit, :id => @comment.to_param
  #   assert_redirected_to login_path
  # end

  # test "should not get edit not authorized" do
  #   user_login
  #   get :edit, :id => @comment.to_param
  #   assert_response(403)
  # end

  # test "should get edit" do
  #   sign_in @user
  #   get :edit, :id => @comment.to_param
  #   assert_response :success
  # end

  # test "should not update comment not logged in" do
  #   put :update, :id => @comment.to_param
  #   assert_redirected_to login_path
  # end

  # test "should not update comment not authorized" do
  #   user_login
  #   put :update, :id => @comment.to_param
  #   assert_response(403)
  # end

  # test "should update comment" do
  #   sign_in @user
  #   put :update, :id => @comment.to_param
  #   assert_redirected_to question_comments_path(@question.to_param)
  # end

  # test "should not destroy comment not logged in" do
  #   assert_difference('Comment.count', 0) do
  #     delete :destroy, :id => @comment.to_param
  #   end

  #   assert_redirected_to login_path
  # end

  # test "should not destroy comment not authorized" do
  #   user_login
  #   assert_difference('Comment.count', 0) do
  #     delete :destroy, :id => @comment.to_param
  #   end

  #   assert_response(403)
  # end

  # test "should destroy comment" do
  #   sign_in @user
  #   assert_difference('Comment.count', -1) do
  #     delete :destroy, :id => @comment.to_param
  #   end

  #   assert_redirected_to question_comments_path(@question.to_param)
  # end

end
