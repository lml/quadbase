#encoding: utf-8

# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'open-uri'
require 'spqr_parser.rb'

class QTImport 

	@@content_types = [['SPQR','SPQR']]

	attr_reader :filename, :content_type, :parser, :transformer

	def self.content_types
		@@content_types
	end

	# def self.add_questions(project,questions)
	# 	for a in 0..(questions.length-1)
	# 		project.add_question!(questions[a])
	# 	end
	# 	return project
	# end

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
		a
	end

	# def self.get_answers(content,parser,transformer,id_num)
	# 	#Find only the relevant answer choices, using the question id number
	# 	answers = Array.new
	# 	z = content.xpath('//presentation//response_lid//response_label')
	# 	for y in 0..(z.length-1)
	# 		label = z[y].attributes["ident"].value
	# 		x = label.match(id_num + "_A")
	# 		if x != nil
	# 			answers << z[y]
	# 		end
	# 	end
	# 	choices = Array.new
	# 	credit = self.get_credit(content,id_num)
	# 	for a in 0..(answers.length-1)
	# 		b = answers[a].children.children.children
	# 		text = b[0].content
	# 		text.gsub(/δ/,"\\delta")
	# 		text.gsub(/ω/,"\\omega")
	# 		text.gsub(/π/,"\\pi")
	# 		b1 = parser.parse(text)
	# 		ans = transformer.apply(b1)			
	# 		choice = AnswerChoice.new(:content => ans, :credit => credit[a])
	# 		choices << choice
	# 	end
	# 	credit.keep_if {|b| b > 0 }
	# 	if credit.length == 0
	# 		choice = AnswerChoice.new(:content => 'fake', :credit => 1)
	# 		choices << choice
	# 	end
	# 	return choices
	# end

	# def self.get_credit(content,id_num)
	# 	numbers = Array.new
	# 	points = Array.new
	# 	a = content.xpath('//resprocessing//respcondition')
	# 	for b in 0..(a.length-1)
	# 		c = a[b].children.children[1].children[0]			
	# 		label = c.content
	# 		d = label.match(id_num + "_A")
	# 		if d != nil
	# 			numbers << a[b]
	# 		end
	# 	end
	# 	for i in 0..(numbers.length-1)
	# 		j = numbers[i].children.children.last
	# 		k = (j.content).to_f
	# 		if k < 0
	# 			k = 0
	# 		end
	# 		points << k
	# 	end		
	# 	credits = self.normalize(points)		
	# end

#Why is this such a roundabout way of getting the question? Well, the 
#questions and answer choices have the same tag, with the answer choices
#nested more deeply.  I can do a specific search for the path the answer
#choices are on and get those back.  But, I can't do a more general 
#search and get only questions back.  Each time it returns the questions
#and answer choices, in sequence, but this is a problem, especially since
#the number of answer choices per question varies widely.  Hence the 
#roundabout method.
	# def self.get_questions(content,parser,transformer)
	# 	ques = Array.new
	# 	ques_id = Array.new
	# 	questions = Array.new
	# 	for z in 0..(content.length-1)
	# 		y = content[z]
	# 		ques_num  = y.attributes["ident"].value
	# 		ques_id << ques_num
	# 	end
	# 	x = content.xpath('//presentation')
	# 	for p in 0..(x.length-1)
	# 		w = x[p].children.children.children
	# 		text = w[0].content
	# 		text.gsub(/δ/,"\\delta")
	# 		text.gsub(/ω/,"\\omega")
	# 		text.gsub(/π/,"\\pi")
	# 		text.force_encoding('UTF-8')
	# 		v = parser.parse(text)
	# 		ques1 = transformer.apply(v)
	# 		ques << ques1
	# 	end
	# 	# debugger
	# 	for a in 0..(ques.length-1)
	# 		answers = self.get_answers(content,parser,transformer,ques_id[a])
	# 		b = Comment.new(:message => ques_id[a])
	# 		q = SimpleQuestion.new(:content => ques[a])
	# 		q.comment_thread = b.comment_thread
	# 		for i in 0..(answers.length-1)
	# 			q.answer_choices << answers[i]
	# 			if answers.length == 0
	# 				q.answer_choices << AnswerChoice.new(:content => "fake", :credit => 0)
	# 				q.answer_choices << AnswerChoice.new(:content => "not real", :credit => 1)
	# 			end
	# 			if answers.length == 1
	# 				q.answer_choices << AnswerChoice.new(:content => "fake", :credit => 0)
	# 			end
	# 		end
	# 		q.save!
	# 		questions << q
	# 	end
	# 	return questions
	# end

#For the SPQR content, it seems that a series of questions are embedded 
#within each <item></item> tag.  As such, we search and save only 
#content within each tag and "discard" the rest.
	def self.iterate_items(document)
		items = document.xpath('//item')
	end

	def self.normalize(array)
		if array.max == 0
			a = 1.0
		else
			a = array.max 
		end
		for z in 0..(array.length-1)
			array[z] = array[z]/a
		end
		return array
	end

	def self.openfile(filename)
		f = File.open(filename)
		doc = Nokogiri::XML(f)
	end

	def self.get_answers(ans_content,credit_content,parser,transformer)
		answers = Array.new
		for z in 0..(ans_content.length-1)
			label = ans_content[z].attributes["ident"].value
			credit, credit_content = self.get_credit(credit_content,label)
			extra_info_start = label.index("A")
			ques_id = label[0..extra_info_start-2]
			y = ans_content[z].children.children.children
			text = y[0].content
			text.gsub("\xCE\xB4","\\delta")
			text.gsub("\xCF\x89","\\omega")
			text.gsub("\xCF\x80","\\pi")
			x = parser.parse(text)
			ans = transformer.apply(x)
			choice = [ques_id,ans,credit]
			answers << choice
		end
		answers
	end

	def self.get_credit(content,id_num)
		for a in 0..(content.length-1)
			b = content[a].children.children[1].children[0]
			label = b.content
			c = label.match(id_num)
			if c != nil
				d = content[a].children.children.last
				credit = (d.content).to_f
				if credit < 0
					credit = 0
				end
				content.delete(content[a])
			end
			unless c == nil
				break
			end
		end
		return credit, content
	end

	def self.get_questions(project, content, parser, transformer,current_user)
		ques_nodes = content.xpath('//presentation')
		ans_nodes = content.xpath('//presentation//response_lid//response_label')
		credit_nodes = content.xpath('//resprocessing//respcondition')
		answers = self.get_answers(ans_nodes,credit_nodes,parser,transformer)
		for a in 0..(content.length-1)
			b = content[a]
			ques_id = b.attributes["ident"].value
			c = ques_nodes[a].children.children.children
			text = c[0].content			
			text.gsub("\xCE\xB4","\\delta")
			text.gsub("\xCF\x89","\\omega")
			text.gsub("\xCF\x80","\\pi")
			d = parser.parse(text)
			ques = transformer.apply(d)
			q = SimpleQuestion.new(:content => ques)
			q.save!
			e = Comment.new(:message => ques_id)
			e.comment_thread = q.comment_thread
			e.creator = current_user
			e.save!
			temp_ans = Array.new
			# debugger
			for f in 0..(answers.length-1)
				if ques_id == answers[f][0]
					temp_ans << answers[f]
				end
			end
			answers.each_index {|j| if answers[j][0] == ques_id then answers.delete_at(j) end }
			if temp_ans.length == 0
				temp_ans << [ques_id,'fake',0]
				temp_ans << [ques_id,'not real',1]
			elsif temp_ans.length == 1
				temp_ans << [ques_id,'fake',0]
			end
			temp_credit = Array.new
			for g in 0..(temp_ans.length-1)
				temp_credit << temp_ans[g][2]
			end
			points = self.normalize(temp_credit)
			if points.max == 0
				temp_ans << [ques_id,'fake',1]
				points << 1.0
			end
			for i in 0..(temp_ans.length-1)
				q.answer_choices << AnswerChoice.new(:content => temp_ans[i][1], :credit => temp_credit[i])
			end
			q.save!
			project.add_question!(q)
		end
	end


end
