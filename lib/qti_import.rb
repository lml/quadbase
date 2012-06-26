#encoding: utf-8

# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'htmlentities'
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

	# def self.get_answers(ans_content,credit_content,parser,transformer)
	# 	answers = Hash.new
	# 	for z in 0..(ans_content.length-1)
	# 		label = ans_content[z].attributes["ident"].value
	# 		credit = self.get_credit(credit_content,label)
	# 		y = ans_content[z].children.children.children
	# 		text = y[0].content
	# 		x = parser.parse(text)
	# 		ans = transformer.apply(x)
	# 		choice = [ans,credit]
	# 		answers[label] = choice
	# 	end
	# 	answers
	# end

	def self.get_credit(content)
		credit = Hash.new
		for a in 0..(content.length-1)
			b = content[a].children.children[1].children[0]
			label = b.content
			c = content[a].children.children.last
			d = (c.content).to_f
				if d < 0
					d = 0
				end			
			credit[label] = d
		end
		return credit
	end

	def self.get_questions(project, content, parser, transformer,current_user)
		coder = HTMLEntities.new
		ques_nodes = content.xpath('//presentation')
		# ans_nodes = content.xpath('//presentation//response_lid//response_label')
		credit_nodes = content.xpath('//resprocessing//respcondition')
		# answers = self.get_answers(ans_nodes,credit_nodes,parser,transformer)
		credit = get_credit(credit_nodes)
		for a in 0..(content.length-1)
			b = content[a]
			ques_id = b.attributes["ident"].value
			c = ques_nodes[a].children.children.children
			text = c[0].content
			text = coder.decode(text)
			d = parser.parse(text)
			ques = transformer.apply(d)
			q = SimpleQuestion.new(:content => ques)
			q.save!
			e = Comment.new(:message => ques_id)
			e.comment_thread = q.comment_thread
			e.creator = current_user
			e.save!
			temp_ans = Array.new
			temp_credit = Array.new
			# debugger
			f = content[a].xpath('.//response_lid//response_label')
			for g in 0..(f.length-1)
				label = f[g].attributes["ident"].value
				temp_credit << credit[label]
				h = f[g].children.children.children
				text = h[0].content
				text = coder.decode(text)
				i = parser.parse(text)
				ans = transformer.apply(i)
				temp_ans << ans
			end
			# answers.each_key {|j| if j.match(ques_id) then answers.delete(j) end }
			if temp_ans.length == 0
				temp_ans << 'fake'
				temp_credit << 0
				temp_ans << 'not real'
				temp_credit << 1
			elsif temp_ans.length == 1
				temp_ans << 'fake'
				temp_credit << 0
			end			
			points = self.normalize(temp_credit)
			if points.max == 0
				temp_ans << 'fake'
				points << 1.0
			end
			for j in 0..(temp_ans.length-1)
				q.answer_choices << AnswerChoice.new(:content => temp_ans[j], :credit => temp_credit[j])
			end
			q.save!
			project.add_question!(q)
		end
	end


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
end
