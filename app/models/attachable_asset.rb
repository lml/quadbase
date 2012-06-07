# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class AttachableAsset < ActiveRecord::Base
  belongs_to :attachable, :polymorphic => true
  belongs_to :asset
  
  before_validation :make_local_name_unique
  validates_uniqueness_of :local_name, :scope => :attachable_id
  after_destroy :destroy_orphan_asset
  
  accepts_nested_attributes_for :asset

  attr_accessible :attachable_id, :attachable_type, :asset, :description, :asset_attributes

  def self.exclude_images(attachable_assets)
    attachable_assets.reject { |aa| aa.asset.is_image? }
  end

  def destroy_orphan_asset
    if asset.attachable_assets.empty?
      asset.destroy
    end
  end
  
  def content_copy
    aa = AttachableAsset.new(:description => self.description, 
                             :attachable_type => self.attachable_type)
    aa.asset_id = self.asset_id
    aa.local_name = self.local_name
    aa
  end
  
  #############################################################################
  # Access control methods
  #############################################################################

  def can_be_read_by?(user)
    !user.is_anonymous? && user.can_read?(attachable)
  end
   
  def can_be_created_by?(user)
    !user.is_anonymous? && user.can_update?(attachable)
  end

  def can_be_destroyed_by?(user)
    !user.is_anonymous? && user.can_update?(attachable)
  end
  
  def self.get_asset(attachable_id, local_name)
    AttachableAsset.find_by_attachable_id_and_local_name(attachable_id, local_name).asset
  end
  
protected

  # TODO 80% of this method could be put into a library that could be reused elsewhere.
  def make_local_name_unique
    local_names = AttachableAsset.find_all_by_attachable_id(attachable_id).collect{|aa| aa.local_name}
    return if !local_names.include?(self.local_name)

    extension = File.extname(self.local_name)
    basename = File.basename(self.local_name, extension)
    
    number = 1
    new_local_name = basename + "_#{number.to_s}" + extension
    
    while local_names.include?(new_local_name)
      number += 1
      new_local_name = basename + "_#{number.to_s}" + extension
    end

    self.local_name = new_local_name
  end

end
