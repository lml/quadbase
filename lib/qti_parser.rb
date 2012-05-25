#encoding: utf-8

# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'parslet'
require 'parslet/convenience'

class QTIParser < Parslet::Parser
	def parse(str)
		super(str)
	end
# [a-z]*[0-9]*\/*-*\.*\?*\\*
	#Check for accompanying images
	rule(:filename)        { match(/[a-z|0-9|\/|\-|\.|\?|\\]/).repeat(1).as(:filename) }
	rule(:image_start_tag) { str('<img src="') }
	rule(:image_end_tag)   { str('">').as(:image_end_tag) }
	rule(:image)           { (image_start_tag.as(:image_start_tag) >> ( filename | image_end_tag ).repeat).as(:image) }

	#Check for formatting
	rule(:italic_tag) { (str("<i>") | str("</i>")).as(:italic) }
	rule(:bold_tag)   { match("<b>" | "</b>").as(:bold) }

	#Single character rules
	rule(:space)      { match("\s").repeat(1) }
	rule(:space?)     { space.maybe }

	#Things 
	rule(:letters) { (match(/\w/) >> space?).repeat(1).as(:letters) }	
	rule(:crlf)    { match("\r\n") >> space? }
	rule(:lf)      { match("\n") >> space? }
	rule(:eol)     { (crlf | lf).as(:eol) }

	#Grammar parts
	rule(:format) { italic_tag }
	rule(:text)   { ( image.as(:image) | format | letters | eol | (any.as(:any)) ).repeat(1) }
	rule(:ques)   { text.repeat(1).as(:text) }

	rule(:expression) { ques }
	root :expression
end

class QTITransform < Parslet::Transform
	rule(:italic => simple(:italic))   {"'"}
	rule(:letters => simple(:letters)) { letters }
	rule(:any => simple(:any))         { any }
	rule(:text => sequence(:entries))  { entries.join}
end
