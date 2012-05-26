# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'open-uri'
require '/home/railsoer/Documents/quadbase/app/models/project.rb'
require '/home/railsoer/Documents/quadbase/lib/spqr_parser.rb'

module ImportQuestions
	def openfile(filename)
		f = File.open(filename)
		doc = Nokogiri::XML(f)
	end

	def savefile(document)
		a = File.open("/home/railsoer/Documents/values.txt",'w') {|f| f.write(document)}		
	end

	def createproject
		a = Project.create(:name => 'Import')
	end
end

# module find_parser
# 	def choose_parser(content_type)
# 		if 
# end

class QTImport 
	include ImportQuestions
	# include 

	attr_reader :filename, :content_type, :parser, :transformer

	def initialize(filename, content_type)
		@filename = filename
		@content_type = content_type
		content = openfile(filename)
		#savefile(content)
		import_project = createproject
		parser, transformer = choose_import(content_type)
	end

	def choose_import(content_type)
		if (content_type == 'SPQR')
			a = SPQRParser.new
			b = SPQRTransform.new
		end
		return a, b
	end
end

try = QTImport.new("/home/railsoer/Documents/QTI_original.xml",'SPQR')
