# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class RegistrationsController < Devise::RegistrationsController

  @@enable_recaptcha = Quadbase::Application.config.enable_recaptcha

  #rescue_from NoMethodError, :with => Proc.new { raise SecurityTransgression }

  def new
    @enable_recaptcha = @@enable_recaptcha
    super
  end

  def create
    build_resource

    resource.username = params[:user][:username]

    @enable_recaptcha = @@enable_recaptcha

    if (!@enable_recaptcha || verify_recaptcha(:model => resource,
         :message => "Your answer did not match the reCAPTCHA. Please try again.")) &&
       resource.save
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up
        sign_in_and_redirect(resource_name, resource)
      else
        set_flash_message :notice, :inactive_signed_up, :reason => resource.inactive_message.to_s
        expire_session_data_after_sign_in!
        redirect_to after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords(resource)
      render 'new'
    end
  end

  def destroy
    resource.disable!
    sign_out_and_redirect(self.resource)
    set_flash_message :notice, :destroyed
  end

end
