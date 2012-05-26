#encoding: utf-8

# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'parslet'
require 'parslet/convenience'

class SPQRParser < Parslet::Parser
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

	#Greek letters
	rule(:phi)   { str("&phi;").as(:phi) }
	rule(:pi)    { str("&pi;").as(:pi) }
	rule(:omega) { str("&omega;").as(:omega) }
	rule(:greek) { phi | pi | omega }

	#Superscripts and Subscripts
	rule(:sub1) { str("<sub>") | str("<SUB>") }
	rule(:con) { match(/[a-z|A-Z|0-9]/).repeat(1).as(:con) }
	rule(:sub2) { str("</sub>") | str("</SUB>") }
	rule(:sub)  { sub1 >> (con | greek).as(:sub) >> sub2 }
	rule(:sup1) { str("<sup>") | str("<SUP>") }
	rule(:sup2) { str("</sup>") | str("</SUP>") }
	rule(:sup)  { sup1 >> (con | greek).as(:sup) >> sup2 }


	#Single character rules
	rule(:space)      { match("\s").repeat(1) }
	rule(:space?)     { space.maybe }

	#Things 
	rule(:letters) { (match(/\w/) >> space?).repeat(1).as(:letters) }	
	rule(:crlf)    { match("\r\n") >> space? }
	rule(:lf)      { match("\n") >> space? }
	rule(:tab)     { match("\t") >> space? }
	rule(:eol)     { (crlf | lf | tab).as(:eol) }
	rule(:fnof)    { str("&fnof;").as(:fnof) }

	#Grammar parts
	rule(:format) { italic_tag | bold_tag | line_break | tt_tag | font | fnof | sub | sup }
	rule(:text)   { ( image | format | letters | eol | new_p | greek | (any.as(:any)) ).repeat(1) }
	rule(:ques)   { text.repeat(1).as(:text) }

	rule(:expression) { ques }
	root :expression
end

#class UnavailableImage < StandardError; end

class SPQRTransform < Parslet::Transform
	rule(:italic => simple(:italic))       {"'"}
	rule(:bold => simple(:bold))           {"!!"}
	rule(:line_break => simple(:break))    {"\n"}
	rule(:ttype => simple(:ttype))         {"$"}
	rule(:para => simple(:para))           {"\n\n"}
	rule(:eol => simple(:eol))             { eol }
	rule(:content_f => simple(:content_f)) {"!!" + content_f + "!!"}
	rule(:font => sequence(:font))         {"#{font[0].to_s}"}
	rule(:phi => simple(:phi))             {"\phi"}
	rule(:pi => simple(:pi))               {"\pi"}
	rule(:omega => simple(:omega))         {"\omega"}
	rule(:fnof => simple(:fnof))           {"f"}
	rule(:con => simple(:con))             { con }
	rule(:sub => simple(:sub))             {"_{" + sub + "}"}
	rule(:sup => simple(:sup))             {"^{" + sup + "}"}
	rule(:letters => simple(:letters))     { letters }
	rule(:any => simple(:any))             { any }
	rule(:image => sequence(:image))       { "MISSING IMAGE: #{image[0].to_s}"}
	rule(:filename => simple(:filename))   { filename.str.gsub(/[\n\t]/, "").strip }
	rule(:text => sequence(:entries))      { entries.join }
end
