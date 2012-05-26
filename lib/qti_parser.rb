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
	rule(:filename)        { match(/[a-z|0-9|\/|\-|\.|\?|\\\n\t\s]/).repeat(1).as(:filename) }
	rule(:image_start_tag) { str('<img src="') }
	rule(:image_end_tag)   { str('">') }
	rule(:image)           { (image_start_tag >> ( filename >> image_end_tag ).repeat(1)).as(:image) }

	#Check for formatting
	rule(:italic_tag) { (str("<i>") | str("</i>") | str("<I>") | str("</I>")).as(:italic) }
	rule(:bold_tag)   { (str("<b>") | str("</b>") | str("<B>") | str("</B>")).as(:bold) }
	rule(:line_break) { (str("<br>") | str("<BR>")).as(:line_break) }
	rule(:tt_tag)     { (str("<tt>") | str("</tt>") | str("<TT>") | str("</TT>")).as(:ttype)}
	rule(:new_p)      { (str("<p>") | str("</p>") | str("<P>") | str("</P>")).as(:para)}

	#Check for any font changes
	rule(:font1)     { str("<font")}
	rule(:extra_f)   { match(/[a-z|A-Z|0-9|\/|\-|\.|\?|\s|\\|\n|\t|\"|=]/).repeat(1)}
	rule(:font2)     { str(">")}
	rule(:font_open) { (font1 >> (extra_f >> font2).repeat(1)) }
	rule(:content_f) { match(/[a-z|A-Z|0-9|\/|\-|\.|\?|\s|\\|\n|\t|\"|=]/).repeat(1).as(:content_f) }
	rule(:font_close) { str("</font>") }
	rule(:font)       { ( font_open >> (content_f >> font_close).repeat(1) ).as(:font) }

	#Single character rules
	rule(:space)      { match("\s").repeat(1) }
	rule(:space?)     { space.maybe }

	#Things 
	rule(:letters) { (match(/\w/) >> space?).repeat(1).as(:letters) }	
	rule(:crlf)    { match("\r\n") >> space? }
	rule(:lf)      { match("\n") >> space? }
	rule(:tab)     { match("\t") >> space? }
	rule(:eol)     { (crlf | lf | tab).as(:eol) }

	#Grammar parts
	rule(:format) { italic_tag | bold_tag | line_break | tt_tag | font }
	rule(:text)   { ( image | format | letters | eol | new_p | (any.as(:any)) ).repeat(1) }
	rule(:ques)   { text.repeat(1).as(:text) }

	rule(:expression) { ques }
	root :expression
end

class UnavailableImage < StandardError; end

class QTITransform < Parslet::Transform
	rule(:italic => simple(:italic))       {"'"}
	rule(:bold => simple(:bold))           {"!!"}
	rule(:line_break => simple(:break))    {"\n"}
	rule(:ttype => simple(:ttype))         {"$"}
	rule(:para => simple(:para))           {"\n\n"}
	rule(:eol => simple(:eol))             { eol }
	rule(:content_f => simple(:content_f)) {"!!" + content_f + "!!"}
	rule(:font => sequence(:font))         {"#{font[0].to_s}"}
	rule(:letters => simple(:letters))     { letters }
	rule(:any => simple(:any))             { any }
	rule(:image => sequence(:parts))       { raise UnavailableImage, "Image #{parts[0].to_s} must be uploaded"}
	rule(:filename => simple(:filename))   { filename.str.gsub(/[\n\t]/, "").strip }
	rule(:text => sequence(:entries))      { entries.join }
end
