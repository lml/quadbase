class ApiKey < ActiveRecord::Base
  belongs_to :user

  before_create :generate_access_token
  before_create :destroy_previous
  
private
  
  def generate_access_token
    begin
      self.access_token = SecureRandom.hex
    end while self.class.exists?(access_token: access_token)
  end

  def destroy_previous
    user.try(:api_key).try(:destroy)
  end

end
