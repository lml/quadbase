#encoding: utf-8

# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'parslet'
require 'parslet/convenience'

class QTIParser < Parslet::Parser
	def parse(str)
		
		rescue image_start_tag.absent?
			puts "You need to attach " + filename + " ."
		rescue Parslet::ParseFailed 
			puts "Sorry, but " + str + " contains unknown characters."
	end

	#Check for accompanying images
	rule(:filename)        { match['a-zA-z0-9_\.-\()\/?\\ '].repeat(1) }
	rule(:image_start_tag) { str("<img src=") }
	rule(:image)           { (image_start_tag >> filename.as(:filename) >> str("\">")).as(:image) }

	#Check for formatting
	rule(:italic_tag) { match("<i>" | "</i>").as(:italic) }
	rule(:bold_tag)   { match("<b>" | "</b>").as(:bold) }

	#Single character rules
	rule(:space)      { match("\s").repeat(1) }
	rule(:space?)     { space.maybe }

	#Things 
	rule(:letters) { (match(/\w/) >> space?).repeat(1) }
	rule(:any)     { match(/./) >> space? }
	rule(:crlf)    { match("\r\n") >> space? }
	rule(:lf)      { match("\n") >> space? }
	rule(:eol)     { crlf | lf }

	#Grammar parts
	rule(:text) { (letters | eol | any ) >> text.repeat }
	rule(:ques) { text.repeat(1) }

	rule(:expression) { ques }
	root :expression
end

class Question_Transform < Parslet::Transform
	rule(:italic) {"'"}
	rule(:bold)   {"!!"}
end