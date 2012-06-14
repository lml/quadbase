# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class Asset < ActiveRecord::Base
  has_attached_file :attachment, :styles => { :medium => "350x350>", :thumb => "100x100>" },
                                 :path => ":rails_root/public/system/:attachment/:id/:style/:filename",
                                 :url => "/system/:attachment/:id/:style/:filename"
  
  has_many :attachable_assets
  has_many :attachables, :through => :attachable_assets
  
  belongs_to :uploader, :class_name => "User"
  
  validates_presence_of :attachment_file_name
  validate :content_type_allowed, :sizes_match
  
  before_post_process :is_image?
  before_create :randomize_file_name

  attr_accessible :attachment

  def is_image?
    ["image/jpeg", "image/pjpeg", "image/jpg", "image/png", "image/x-png", "image/gif"].include?(self.attachment_content_type) 
  end
  
  def is_pdf?
    "application/pdf" == self.attachment_content_type
  end
  
  def is_allowed_type?
    is_image? || is_pdf?
  end
  
  def file_base_name
    File.basename(attachment_file_name, File.extname(attachment_file_name))
  end
  
  def path(size = :original)
    "system/attachments/#{id}/#{size}/#{attachment_file_name}"
  end

private

  def randomize_file_name
    extension = File.extname(attachment_file_name).downcase
    self.attachment.instance_write(:file_name, "#{SecureRandom.hex(16)}#{extension}")
  end
  
  def content_type_allowed
    errors.add(:attachment, "is not an allowed file type") if !is_allowed_type?
  end

  def sizes_match
    return if attachment_file_size == attachment.size
    errors.add(:attachment, "has the wrong file size")
    false
  end

end
