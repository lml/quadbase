# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class AttachableAssetsController < ApplicationController
  
  skip_filter :protect_beta, :only => :create

  def create
    # Update some of the input parameters (correct the MIME type, set the uploader
    # information, provide an initial local file name)
    
    original_filename = params[:attachable_asset][:asset_attributes][:attachment].original_filename
    corrected_content_type = MIME::Types.type_for(original_filename.to_s).first
    params[:attachable_asset][:asset_attributes][:attachment].content_type = corrected_content_type

    @attachable_asset = AttachableAsset.new(params[:attachable_asset])
    @attachable_asset.local_name = original_filename
    @attachable_asset.asset.uploader = current_user

    raise SecurityTransgression unless present_user.can_create?(@attachable_asset)
    
    respond_to do |format|
      if @attachable_asset.save
         @attachable = @attachable_asset.attachable
         format.any {
           render :text => @attachable_asset.id
         }
      else
        logger.debug {@attachable_asset.errors.inspect}
        format.json { render :json => @attachable_asset.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # Uploadify is limited in what it can do with the response from the create
  # method.  Therefore, we have the uploadify success handlers call the 
  # finish_create method which has js.erb to finish the job. 
  def finish_create
    @attachable_asset = AttachableAsset.find(params[:attachable_asset_id])
  end

  def destroy
    @attachable_asset = AttachableAsset.find(params[:id])

    raise SecurityTransgression unless present_user.can_destroy?(@attachable_asset)

    respond_to do |format|
      if @attachable_asset.destroy
         format.html { case @attachable_asset.attachable_type
                       when "Solution"
                         redirect_to(question_solutions_path(
                                       @attachable_asset.attachable.question))
                       else
                         redirect_to(questions_path)
                       end }
         format.js
      else
        logger.debug {@attachable_asset.errors.inspect}
        format.json { render :json => @attachable_asset.errors, :status => :unprocessable_entity }
      end
    end
  end

  def download
    @attachable_asset = AttachableAsset.find(params[:attachable_asset_id])

    raise SecurityTransgression unless present_user.can_read?(@attachable_asset)

    send_file @attachable_asset.asset.attachment.path, 
              :filename => @attachable_asset.local_name,
              :type => @attachable_asset.asset.attachment_content_type
  end

end
