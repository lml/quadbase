# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'open-uri'
require 'project.rb'
require 'question.rb'
require 'spqr_parser.rb'
require 'answer_choice.rb'

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
		items = document.xpath('//item')
	end

	def get_questions(content,parser,transformer)
		a = content[0]
		ques_num = a.attributes["ident"]

		#Why is this such a roundabout way of getting the question? Well, the 
		#questions and answer choices have the same tag, with the answer choices
		#nested more deeply.  I can do a specific search for the path the answer
		#choices are on and get those back.  But, I can't do a more general 
		#search and get only questions back.  Each time it returns the questions
		#and answer choices, in sequence, but this is a problem, especially since
		#the number of answer choices per question varies widely.  Hence the 
		#roundabout method.
		b = a.xpath('//presentation')
		c = b[0].children.children.children
		text = c[0].content
		b1 = parser.parse(text)
		ques = transformer.apply(b1)

		answers = get_answers(a,parser,transformer)
		fake_ans = AnswerChoice.new(:content => "fake", :credit => 1)

		q = SimpleQuestion.new(:content => ques )
		q.answer_choices << answers
		q.answer_choices << fake_ans
		
		q.save!
		return q
	end

	def get_answers(content,parser,transformer)
		a = content.xpath('//presentation//response_lid//mattext')
		b = a[0]
		text = (b.children[0]).content
		b1 = parser.parse(text)
		ans = transformer.apply(b1)
		credit = get_credit(content)

		choice = AnswerChoice.new(:content => ans, :credit => credit[0])
	end

	def get_credit(content)
		a = content.xpath('//resprocessing')
		b = a[0].children.children.children
		b.remove_attr("respident")
		b.children.remove
		len = b.length
		points = Array.new
		for z in 0..(len-1)
			y = b[z].element?()			
			if y == false
				x = b[z].content
				w = x.match(/\D/)
				if w == nil
					points << x.to_f
				end
			end
		end
		credits = normalize(points)		
	end

	def normalize(array)
		a = array.max 
		for z in 0..(array.length-1)
			array[z] = array[z]/a
		end
		return array
	end


end

module AddQuestions
	def add_questions(project,questions)
	end
end

class QTImport 
	include ImportQuestions
	include GetContent
	include AddQuestions

	attr_reader :filename, :content_type, :parser, :transformer

	def initialize(filename, content_type)
		@filename = filename
		@content_type = content_type
		document = openfile(filename)
		import_project = createproject
		parser, transformer = choose_import(content_type)
		content = iterate_items(document)
		questions = get_questions(content,parser,transformer)
		add_questions(import_project,questions)
	end
private
	def choose_import(content_type)
		if (content_type == 'SPQR')
			a = SPQRParser.new
			b = SPQRTransform.new
		end
		return a, b
	end
end

try = QTImport.new("/home/railsoer/Documents/QTI_original.xml",'SPQR')
