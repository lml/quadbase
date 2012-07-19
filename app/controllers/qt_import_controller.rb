#encoding: utf-8

# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'mime/types'

class QtImportController < ApplicationController
	def new
		@content_types = QTImport.content_types
	end

	def create
		begin
			a = params[:file]
			a,images =  QTImport.unzip(a.path,"#{Rails.root}/tmp/import") if a.content_type == 'application/zip'
			document = QTImport.openfile(a.path)
			project = QTImport.createproject(current_user)
			parser, transformer = QTImport.choose_import(params[:content_type])
			content = QTImport.iterate_items(document)	
			QTImport.get_questions(project,content,parser,transformer,current_user) unless images
			QTImport.get_questions(project,content,parser,transformer,current_user,images) unless !images
		
		rescue			
			flash[:alert] = 'Unfortunately we could not import all of your questions.  This may be due to formatting errors in your questions, such as HTML.
However, we were most likely able to import some of your questions.  They are listed under a new project called Import, and are now unpublished questions.'
			redirect_to :action => :new		
		end
    end
end
