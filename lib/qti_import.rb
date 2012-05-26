# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'open-uri'
require '/home/railsoer/Documents/quadbase/app/models/project.rb'
require '/home/railsoer/Documents/quadbase/app/models/question.rb'
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

#For the SPQR content, it seems that a series of questions are embedded 
#within each <item></item> tag.  As such, we search and save only 
#content within each tag and "discard" the rest.
module GetContent
	def iterate_items(document)
		items = document.xpath('//item').to_a
	end

	def get_questions(content)
		a = content[0]
		inter = a.attributes["ident"]
		ques_name = inter.value
		number = get_q_id(ques_name)
		p ques_name
		p number
	end

	def get_q_id(str)
		value = (str.gsub("QUE_","")).to_i
	end


end

class QTImport 
	include ImportQuestions
	include GetContent

	attr_reader :filename, :content_type, :parser, :transformer

	def initialize(filename, content_type)
		@filename = filename
		@content_type = content_type
		document = openfile(filename)
		import_project = createproject
		parser, transformer = choose_import(content_type)
		content = iterate_items(document)
		get_questions(content)
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
