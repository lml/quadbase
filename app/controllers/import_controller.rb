class ImportController < ApplicationController
	def index
		@qt_import = QtImport.new
	end
end
