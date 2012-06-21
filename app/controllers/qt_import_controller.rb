#encoding: utf-8

# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

class QtImportController < ApplicationController
	def new
		@content_types = QTImport.content_types
	end

	def create
		f = params[:file]
		document = QTImport.openfile(f.path)
		parser, transformer = QTImport.choose_import(params[:content_type])
		content = QTImport.iterate_items(document)
		debugger
		questions = QTImport.get_questions(content,parser,transformer)
		project = QTImport.createproject(current_user)
		QTImport.add_questions(project,questions)

	# rescue
	# 	render :text => "Sorry, there was a problem with importing your questions."
	# 	redirect_to :new
	# end
    end
end
