#encoding: utf-8

# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'htmlentities'
require 'open-uri'
require 'spqr_parser.rb'
require 'archive/zip'

class QTImport 

	@@content_types = [['SPQR']]

	attr_reader :filename, :content_type, :parser, :transformer

	def self.add_assets(asset_names,asset_list,question)
		asset_names.each { |z|
		y = AttachableAsset.new(:asset => asset_list[z])
		y.local_name = File.basename(z)
		y.save! 
		question.attachable_assets << y 
		question.save! }
		question
	end

	def self.add_images(content,text)
		a = content.xpath('.//matimage')
		for b in 0..(a.length-1)
			c = a[b].attributes['uri'].value
			d = text + ' <img src="' + c + '">'
		end
		d
	end

	def self.content_types
		@@content_types
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
		a
	end

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

	def self.get_images(images)
		pictures = Hash.new
		key_name = "/media"
		Dir.chdir(images)
		z = Dir.entries(images)
		z.each { |y| 
			if !File.fnmatch('..',y) && !File.fnmatch('.',y)
				if File.directory?(y)
					x = File.join(key_name,y)
					v = File.join(images,y)
					u = Dir.entries(v)
					u.each { |t| 
						if !File.directory?(t)
						 s = File.join(v,t)
						 r = File.join(x,t)
						 q = File.open(s)
						 p = Asset.new(:attachment => q)
						 p.save!
						 pictures[r] = p
						 q.close
						end }
				end
			end }
		pictures
	end

	def self.get_questions(project, content, parser, transformer,current_user,*images)
		if !images.blank?
			pictures = self.get_images(images[0].to_s)
		end
		coder = HTMLEntities.new
		ques_nodes = content.xpath('//presentation')
		credit_nodes = content.xpath('//resprocessing//respcondition')
		credit = get_credit(credit_nodes)
		for a in 0..(content.length-1)
			b = content[a]
			ques_id = b.attributes["ident"].value
			c = ques_nodes[a].children.children.children			
			text = c[0].content
			text = self.add_images(ques_nodes,text)
			text = coder.decode(text)
			d = parser.parse(text)
			transformer.clear_pictures
			ques = transformer.apply(d)
			pic_names1 = transformer.pictures
			q = SimpleQuestion.new(:content => ques)
			q.save!
			e = Comment.new(:message => ques_id)
			e.comment_thread = q.comment_thread
			e.creator = current_user
			e.save!
			if !pic_names1.blank?
				q = self.add_assets(pic_names1,pictures,q)
			end
			temp_ans = Array.new
			temp_credit = Array.new
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
			points = self.normalize(temp_credit)
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
		raise StandardError if items.blank?
		items
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
		array
	end

	def self.openfile(filename)
		f = File.open(filename)
		doc = Nokogiri::XML(f)
		f.close
		doc
	end

	#This will unzip files and return the appropriate files.  We check
	#the content type of each file to ensure that no "hidden" files (".","..")
	#are
	def self.unzip(zipfile,destination)
		info = Hash.new
		Archive::Zip.extract(zipfile,destination)
		Dir.chdir(destination + "/content")
		a = Dir.entries(Dir.pwd)
		a.each { |b| 
			if File.file?(b)
				c = File.open(b)
				info['file'] = c
				c.close
			else File.directory?(b)
				if !File.fnmatch('..',b) && !File.fnmatch('.',b)
					d = File.join(Dir.pwd,b)
					info['images'] = d
				end
			end }
		return info['file'], info['images']
	end
end
