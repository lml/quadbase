#encoding: utf-8

# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'parslet'
require 'parslet/convenience'

class QTIParser < Parslet::Parser
	def parse(str)
		super(str)
	end

	#Check for accompanying images
	rule(:filename)        { match['a-zA-z0-9_\.-\()\/?\\ '].repeat(1) }
	rule(:image_start_tag) { match('<img src=\"') }
	rule(:image)           { (image_start_tag >> filename.as(:filename) >> str("\">")).as(:image) }

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
	rule(:text)   { ( format | letters | eol | (any.as(:any)) ).repeat(1) }
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
