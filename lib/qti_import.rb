# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'open-uri'
require 'spqr_parser.rb'

class QTImport 

	@@content_types = ['SPQR']

	attr_reader :filename, :content_type, :parser, :transformer

	def self.content_types
		@@content_types
	end

	def self.add_questions(project,questions)
		for a in 0..(questions.length-1)
			project.add_question!(questions[a])
		end
	end

	def self.choose_import(content_type)
		if (content_type == 'SPQR')
			a = SPQRParser.new
			b = SPQRTransform.new
		end
		return a, b
	end

	def self.createproject(current_user)
		a = Project.create(:name => 'Import')
		a.add_member!(current_user)
	end

	def self.get_answers(content,parser,transformer,id_num)
		#Find only the relevant answer choices, using the question id number
		answers = Array.new
		z = content.xpath('//presentation//response_lid//response_label')
		for y in 0..(z.length-1)
			label = z[y].attributes["ident"].value
			x = label.match(id_num + "_A")
			if x != nil
				answers << z[y]
			end
		end
		choices = Array.new
		credit = self.get_credit(content,id_num)
		for a in 0..(answers.length-1)
			b = answers[a].children.children.children
			text = b[0].content
			b1 = parser.parse(text)
			ans = transformer.apply(b1)
			choice = AnswerChoice.new(:content => ans, :credit => credit[a])
			choices << choice
		end
		return choices
	end

	def self.get_credit(content,id_num)
		numbers = Array.new
		points = Array.new
		a = content.xpath('//resprocessing//respcondition')
		for b in 0..(a.length-1)
			c = a[b].children.children[1].children[0]			
			label = c.content
			d = label.match(id_num + "_A")
			if d != nil
				numbers << a[b]
			end
		end
		for i in 0..(numbers.length-1)
			j = numbers[i].children.children.last
			k = (j.content).to_f
			points << k
		end		
		credits = self.normalize(points)		
	end

#Why is this such a roundabout way of getting the question? Well, the 
#questions and answer choices have the same tag, with the answer choices
#nested more deeply.  I can do a specific search for the path the answer
#choices are on and get those back.  But, I can't do a more general 
#search and get only questions back.  Each time it returns the questions
#and answer choices, in sequence, but this is a problem, especially since
#the number of answer choices per question varies widely.  Hence the 
#roundabout method.
	def self.get_questions(content,parser,transformer)
		ques = Array.new
		ques_id = Array.new
		questions = Array.new
		for z in 0..(content.length-1)
			y = content[z]
			ques_num  = y.attributes["ident"].value
			ques_id << ques_num
			x = y.xpath('//presentation')
			w = x[0].children.children.children
			text = w[0].content
			v = parser.parse(text)
			ques1 = transformer.apply(v)
			ques << ques1
		end		
		answers = self.get_answers(content,parser,transformer,ques_num)
		for a in 0..(ques.length-1)
			b = Comment.new(:message => ques_id[a])
			q = SimpleQuestion.new(:content => ques[a])
			q.comment_thread = b.comment_thread
			for i in 0..(answers.length-1)
				q.answer_choices << answers[i]
			end
			q.save!
			questions << q
		end
		return questions
	end

#For the SPQR content, it seems that a series of questions are embedded 
#within each <item></item> tag.  As such, we search and save only 
#content within each tag and "discard" the rest.
	def self.iterate_items(document)
		items = document.xpath('//item')
	end

	def self.normalize(array)
		a = array.max 
		for z in 0..(array.length-1)
			array[z] = array[z]/a
		end
		return array
	end

	def self.openfile(filename)
		f = File.open(filename)
		doc = Nokogiri::XML(f)
	end


end
