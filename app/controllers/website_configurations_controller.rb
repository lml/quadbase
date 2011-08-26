# Copyright (c) 2011 Rice University.  All rights reserved.

class WebsiteConfigurationsController < AdminController

  # GET /website_configurations
  def index
    raise SecurityTransgression unless present_user.can_read?(WebsiteConfiguration)

    @website_configurations = WebsiteConfiguration.all
  end

  # GET /website_configurations/edit
  def edit
    raise SecurityTransgression unless present_user.can_update?(WebsiteConfiguration)

    @website_configurations = WebsiteConfiguration.all
  end

  # PUT /website_configurations
  def update
    raise SecurityTransgression unless present_user.can_update?(WebsiteConfiguration)

    @website_configurations = WebsiteConfiguration.all

    begin
      WebsiteConfiguration.transaction do
        @website_configurations.each do |configuration|
          configuration.update_attribute(:value, params[configuration.name])
        end
      end
    rescue ActiveRecord::RecordInvalid => invalid
      render :action => "edit", :notice => 'An error has occurred.'
      return
    end
    redirect_to(website_configurations_path,
                :notice => 'Website configuration was successfully updated.')
  end
end
