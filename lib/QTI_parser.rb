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
	rule(:space)        { match('\s').repeat(1) }
	rule(:space?)       { space.maybe }

	#Things 
	rule(:letters) { match['A-Za-z'].repeat(1) >> space? }
	rule(:numbers) { match['0-9'].repeat(1) >> space? } 
	rule(:period)  { match('\.') >> space? }
	rule(:star)    { match('\*') >> space? }
	rule(:fslash)  { match('\/') >> space? }
	rule(:bslash)  { match('\\') >> space? }
	rule(:any)     { match('.') >> space? }

	#Grammar parts
	rule(:punc) { period | star | fslash | bslash }
	rule(:ques) { (letters | numbers | punc | any ) >> ques.repeat }
	

	rule(:expression) { ques }
	root :expression
end
