# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'parslet'
require 'parslet/convenience'

class QuestionParser < Parslet::Parser
	def parse(str)
		#p question.parse(str)

		rescue Parslet::ParseFailed 
			puts "Sorry, but " + str + " contains unknown characters."
	end

	#Single character rules
	rule(:leftbracket)  { str('[') }
	rule(:rightbracket) { str(']') }
	rule(:exclamation)  { str('!') }
	rule(:lessthan)     { str('<') >> space? }
	rule(:greaterthan)  { str('>') >> space? }
	rule(:colon)        { str(':') >> space? }
	rule(:equal)        { str('=') >> space? }
	rule(:semicolon)    { str(';') >> space? }
	rule(:lparen)       { str('(') >> space? }
	rule(:rparen)       { str(')') >> space? }
	rule(:qmark)        { str('?') >> space? }
	rule(:underscore)   { str('_') >> space? }
	rule(:doublequote)  { str('"') >> space? }
	rule(:ampersand)    { str('&') >> space? }
	rule(:comma)        { str(',') >> space? }
	rule(:percent)      { str('%') >> space? }
	rule(:caret)        { str('^') >> space? }
	rule(:dash)         { str('-') >> space? }

	rule(:space)        { match('\s').repeat(1) }
	rule(:space?)       { space.maybe }

	#Things 
	rule(:letters) { match['A-Za-z'].repeat(1) >> space? }
	rule(:numbers) { match['0-9'].repeat(1) >> space? } 
	rule(:period)  { match('\.') >> space? }
	rule(:star)    { match('\*') >> space? }
	rule(:fslash)  { match('\/') >> space? }
	rule(:bslash)  { match('\\') >> space? }

	#Grammar parts
	rule(:punc)       { colon | greaterthan | lessthan | equal | 
		semicolon | lparen | rparen | period | star | fslash | 
		qmark | underscore | doublequote | ampersand | comma | 
		percent | caret | dash | bslash }
	rule(:begin_ques) { lessthan >> exclamation >> leftbracket >> 
		letters >> leftbracket }
	rule(:ques)       { (letters | numbers | punc | end_ques ) >> ques.repeat }
	rule(:end_ques)   { rightbracket >> rightbracket >> greaterthan }

	rule(:expression) { (begin_ques >> ques) | ques }
	root :expression
end
