class ApiKeysController < ApplicationController

  before_filter :get_user

  def new
    @api_key = ApiKey.new
  end

  def create
    raise SecurityTransgression unless current_user == @user
    @api_key = ApiKey.new
    @api_key.user = @user
    @api_key.save
  end

protected

  def get_user
    @user = User.find(params[:user_id])
  end

end
