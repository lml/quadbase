#encoding: utf-8

# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'open-uri'
require 'spqr_parser.rb'

class TestImport 

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
		# a.add_member!(current_user)
		a
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
			for f in 0..(answers.length-1)
				if ques_id == answers[f][0]
					temp_ans << answers[f]
					answers.delete_at(f)
				end
			end
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