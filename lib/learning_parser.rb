# encoding: utf-8
require 'parslet'

class Mini < Parslet::Parser
	#Single character rules
	rule(:lparen) { str('(') >> space? }
	rule(:rparen) { str(')') >> space? }
	rule(:comma)  { str(',') >> space? }

	rule(:space)  { match('\s').repeat(1) }
	rule(:space?) { space.maybe }

	#Things
	rule(:integer)    { match('[0-9]').repeat(1).as(:int) >> space?}
	rule(:identifier) { match['a-z'].repeat(1) }
	rule(:operator)   { match('[+]') >> space? }

	#Grammar parts
	rule(:sum)     { integer.as(:left) >> operator.as(:op) >> expression.as(:right) }
	rule(:arglist) { expression >> (comma >> expression).repeat }
	rule(:funcall) { identifier.as(:funcall) >> lparen >> arglist.as(:arglist) >> rparen }

	rule(:expression) { funcall | sum | integer }
	root :expression
end


def parse(str)
	mini = Mini.new
	print "Parsing #{str}: "

	p mini.parse(str)

	rescue Exception
		puts "Sorry, but " + str + " contains non-ASCII characters. Please replace with the correct formatting."
end

parse 'puts(1 + 2 + 3, ω)'
