class FileUpload < ActiveRecord::Base
	mount_uploader :importfile, QuestionUploader

	def extension_white_list
		%w(xml)
	end
end
