class QtImportController < ApplicationController
	def new
		@content_types = QTImport.content_types
	end

	def create
		
    end
end
