class QtImportController < ApplicationController
	def new
		@content_types = QTImport.content_types
	end

	def create
		f = FileUpload.new
		f.importfile.cache!(@file)
		storage = f.importfile.cache_name
		document = QTImport.openfile(f.retrieve_from_cache!(storage))
		parser, transformer = QTImport.choose(@content_types)
		content = QTImport.iterate_items(document)
		questions = QTImport.get_questions(content,parser,transformer)
		project = QTImport.createproject(@current_user)
		QTImport.add_questions(project,questions)

		render 'create'

	# rescue
	# 	render :text => "Sorry, there was a problem with importing your questions."
	# 	redirect_to :new
	# end
    end
end
