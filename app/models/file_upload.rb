class FileUpload < ActiveRecord::Base
	mount_uploader :importfile, QuestionUploader
end
