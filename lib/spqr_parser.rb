# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'parslet'
require 'parslet/convenience'

class SPQRParser < Parslet::Parser

	#Check for accompanying images
	rule(:file)            { space? >> str('src="') >> name >> str('"') }
	rule(:name)            { match(/[a-z|A-Z|0-9|\/|\-|\.|\?|\s|\\|\n|\t|\_|\{|\}|=]/).repeat(1).as(:filename) }
	rule(:image_start_tag) { str('<img') | str("<IMG") }
	rule(:image_end_tag)   { str('>') }
	rule(:quote)           { str('"')}
	rule(:attribute_con)   { match(/[a-z|A-Z|0-9|\/|\-|\.|\?|\s|\\|\n|\t|\_|\{|\}|=]/)}
	rule(:attribute)       { attribute_con >> quote >> attribute_con >> quote }
	rule(:image)           { (image_start_tag >> space? >> (( file | attribute ).repeat(1)) >> space? >> image_end_tag.maybe ).as(:image) }

	#Check for any external links
	rule(:link1)     { str("<a") | str("<A") }
	rule(:link2)     { str(">") }
	rule(:address)   { match(/[a-z|A-Z|0-9|\/|\-|\.|\?|\s|\\|\n|\t|\_|\{|\}|=|]/).repeat(1).as(:address) }
	rule(:link_info) { space? >> str("href=") >> quote.maybe >> address >> quote.maybe }
	rule(:link)      { (link1 >> space? >> (( link_info | attribute).repeat(1)) >> space? >> link2.maybe ) }
	rule(:link_name) { match(/[a-z|A-Z|0-9|\/|\-|\.|\?|\s|\\|\n|\t|\_|\{|\}|=|\"]/).repeat(1).as(:link_name) }
	rule(:link_end)  { str("</a>") | str("</A>") }
	rule(:link_full) { ( link >> link_name.maybe >> link_end ).as(:link_info)}

	#Check for formatting
	rule(:italic_tag) { (str("<i>") | str("</i>") | str("<I>") | str("</I>")).as(:italic) }
	rule(:bold_tag)   { (str("<b>") | str("</b>") | str("<B>") | str("</B>")).as(:bold) }
	rule(:line_break) { (str("<br>") | str("<BR>")).as(:line_break) }
	rule(:tt_tag)     { (str("<tt>") | str("</tt>") | str("<TT>") | str("</TT>")).as(:ttype)}
	rule(:new_p)      { (str("<p>") | str("</p>") | str("<P>") | str("</P>")).as(:para)}
	rule(:center)     { (str("<center>") | str("</center>") | str("<CENTER>") | str("</CENTER>")).as(:center)}
	rule(:code)       { (str("<code>") | str("<CODE>") | str("</code>") | str("</CODE>")).as(:code)}

	#Two exclamation points in a row signifiy a bold tag, so those should be changed to avoid confusion.
	rule(:exclamation) { str("!!").repeat(1).as(:exclamation) }

	#Things to be changed to HTML entities
	rule(:asterisk)   { str("*").as(:asterisk)}
	rule(:lthan)      { str("<").as(:lthan) }
	rule(:gthan)      { str(">").as(:gthan) }
	rule(:apos)       { str("'").as(:apos) }
	rule(:quote1)     { str('"').as(:quote1)}
	rule(:dollar)     { str("$").as(:dollar) }
	rule(:pound)      { str("\#").as(:pound) }
	rule(:entities)   { asterisk | apos | quote1 | dollar | pound }

	#Check for any font changes
	rule(:font1)      { str("<font") | str("<FONT") }
	rule(:extra)      { match(/[a-z|A-Z|0-9|\/|\-|\.|\?|\s|\\|\n|\t|\"|\_|\{|\}|=]/).repeat(1)}
	rule(:font2)      { str(">")}
	rule(:font_open)  { font1 >> extra.maybe >> font2 }
	rule(:content_f)  { ( tags | format | letters | eol | new_p | greek | (punc.as(:any)) ).repeat.as(:content_f)  }
	rule(:font_close) { str("</font>") | str("</FONT>") }
	rule(:font)       { ( font_open >> content_f >> font_close ).as(:font) }

	#Check for any special display classes
	rule(:pre1)      { str("<pre") | str("<PRE") }
	rule(:pre2)      { str(">") }
	rule(:pre_open)  { pre1 >> extra.maybe >> pre2 }
	rule(:content_p) { ( tags | format | letters | eol | new_p | greek | (punc.as(:any)) ).repeat.as(:content_p) }
	rule(:pre_close) { str("</pre>") | str("</PRE>") }
	rule(:pre)       { ( pre_open >> content_p >> pre_close ).as(:pre) }

	rule(:span1)      { str("<span") | str("<SPAN") }
	rule(:span2)      { str(">") }
	rule(:span_open)  { span1 >> extra.maybe >> span2 }
	rule(:content)    { ( tags | format | letters | eol | new_p | greek | (punc.as(:any)) ).repeat.as(:content) }
	rule(:span_close) { str("</span>") | str("</SPAN>") }
	rule(:span)       { ( span_open >>  content >> span_close ).as(:span) }

	rule(:div1)      { str("<div") | str("<DIV") }
	rule(:div2)      { str(">") }
	rule(:div_open)  { div1 >> extra.maybe >> div2 }
	rule(:div_close) { str("</div>") | str("</DIV>") }
	rule(:div)       { ( div_open >>  content >> div_close ).as(:div)}

	#Greek letters
	rule(:delta) { str("\\xCE\\xB4").as(:delta) }
	rule(:phi)   { str("&phi;").as(:phi) }
	rule(:pi)    { ( str("&pi;") | str("\\xCF\\x80") ).as(:pi) }
	rule(:omega) { ( str("&omega;") | str("\\xCF\\x89") ).as(:omega) }
	rule(:greek) { delta | phi | pi | omega }

	#Superscripts and Subscripts
	rule(:sub1) { str("<sub>") | str("<SUB>") }
	rule(:con)  { match(/[a-z|A-Z|0-9]/).repeat(1).as(:con) }
	rule(:sub2) { str("</sub>") | str("</SUB>") }
	rule(:sub)  { sub1 >> (con | greek | punc.as(:any)).as(:sub) >> sub2 }
	rule(:sup1) { str("<sup>") | str("<SUP>") }
	rule(:sup2) { str("</sup>") | str("</SUP>") }
	rule(:sup)  { sup1 >> space? >>(con | greek | punc.as(:any)).repeat.as(:sup) >> sup2 }


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
	rule(:punc)   { match(/[^<]/) }
	rule(:tags)   { font | pre | span | div | image | link_full }
	rule(:format) { italic_tag | bold_tag | line_break | tt_tag | sub | sup | center | entities | exclamation | code }
	rule(:text)   { ( tags | format | letters | eol | new_p | greek | entities | lthan | gthan | (any.as(:any)) ).repeat(1) }
	rule(:ques)   { text.repeat.as(:text) }

	rule(:expression) { ques }
	root :expression
end

#class UnavailableImage < StandardError; end

class SPQRTransform < Parslet::Transform
	rule(:image => sequence(:image))           { "\[#{image[0].to_s}\]"}
	rule(:filename => simple(:filename))       { filename.str.gsub(/[\n\t]/, "").strip }
	rule(:address => simple(:address))         { "\[LINK TO: #{address.to_s}\] "}
	rule(:link_name => simple(:link_name))     { link_name }
	rule(:link_info => simple(:link_info))     { link_info }
	rule(:link_info => sequence(:info))        { info.join }
	rule(:italic => simple(:italic))           {"''"}
	rule(:bold => simple(:bold))               {"!!"}
	rule(:line_break => simple(:break))        {"\n"}
	rule(:ttype => simple(:ttype))             {"$"}
	rule(:para => simple(:para))               {"\n\n"}
	rule(:center => simple(:center))           {}
	rule(:code => simple(:code))               {}
	rule(:exclamation => simple(:exclamation)) {"!"}
	rule(:asterisk => simple(:asterisk))       {'&times;'}
	rule(:lthan => simple(:lthan))             {'&lt;'}
	rule(:gthan => simple(:gthan))             {'&gt;'}
	rule(:apos => simple(:apos))               {'&apos;'}
	rule(:quote1 => simple(:quote1))           {'&quot;'}
	rule(:dollar => simple(:dollar))           {'&dollar;'}
	rule(:pound => simple(:pound))             {'&pound;'}
	rule(:content_f => sequence(:content_f))   {"''" + content_f.join + "''"}
	rule(:font => simple(:font))               { font }
	rule(:content_p => sequence(:content_p))   {"$$" + content_p.join + "$$"}
	rule(:pre => simple(:pre))                 { pre }
	rule(:content => sequence(:content))       { content.join}
	rule(:span => simple(:span))               { span }
	rule(:div => simple(:div))                 { div }
	rule(:delta => simple(:delta))             {"\\delta"}
	rule(:phi => simple(:phi))                 {"\\phi"}
	rule(:pi => simple(:pi))                   {"\\pi"}
	rule(:omega => simple(:omega))             {"\\omega"}
	rule(:con => simple(:con))                 { con }
	rule(:sub => simple(:sub))                 {"_{" + sub + "}"}
	rule(:sup => sequence(:sup))               {"^{" + sup.join + "}"}
	rule(:letters => simple(:letters))         { letters }
	rule(:eol => simple(:eol))                 {}
	rule(:any => simple(:any))                 { any }
	rule(:text => sequence(:entries))          { entries.join }
end
