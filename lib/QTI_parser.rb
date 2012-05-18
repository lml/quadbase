# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'parslet'
require 'parslet/convenience'

class Question < Parslet::Parser
	#Single character rules
	rule(:leftbracket)  { str('[') }
	rule(:rightbracket) { str(']') }
	rule(:exclamation)  { str('!').repeat(1) }
	rule(:lessthan)     { str('<').repeat(1) >> space? }
	rule(:greaterthan)  { str('>').repeat(1) >> space? }
	rule(:colon)        { str(':') >> space? }
	rule(:equal)        { str('=') >> space? }
	rule(:semicolon)    { str(';') >> space? }
	rule(:lparen)       { str('(') >> space? }
	rule(:rparen)       { str(')') >> space? }
	rule(:qmark)        { str('?') >> space? }
	rule(:underscore)   { str('_') >> space? }
	
	rule(:space)        { match('\s').repeat(1) }
	rule(:space?)       { space.maybe }

	#Things 
	rule(:letters) { match['A-Za-z'].repeat(1) >> space? }
	rule(:numbers) { match['0-9'].repeat(1) >> space? } 
	rule(:period)  { match('\.') >> space? }
	rule(:star)    { match('\*') >> space? }
	rule(:fslash)  { match('\/') >> space? }

	#Grammar parts
	rule(:punc)       { colon | greaterthan | lessthan | equal | 
		semicolon | lparen | rparen | period | star | fslash | 
		qmark | underscore }
	rule(:begin_ques) { lessthan >> exclamation >> leftbracket >> 
		letters >> leftbracket }
	rule(:ques)       { (letters | numbers | punc | end_ques ) >> ques.repeat }
	rule(:end_ques)   { rightbracket >> rightbracket >> greaterthan }

	rule(:expression) { begin_ques >> ques }
	root :expression
end

def parse(str)
	question = Question.new
	p question.parse(str)

rescue Parslet::ParseFailed => error
	puts error, question.root.error_tree

end


parse "<![CData[Given:<BR><BR><B><TT>fs = 11025;<BR>tt = (0:round(0.25*fs
	))/fs;</TT></B><BR><BR>Which MATLAB code would you use to gene
rate the appropriate DTMF signal to represent telephone key number
 <B>5</B>? And this is another way.]]>"
