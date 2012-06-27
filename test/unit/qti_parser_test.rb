#encoding: utf-8

# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'
require 'parslet/convenience'

class QTIParserTest < ActiveSupport::TestCase

	def setup
		@parser = QTIParser.new
	end

	test "space" do 
		parser = QTIParser.new
		assert_equal parser.space.parse(" ").to_s, " "
	end

	test "space?" do
		parser = QTIParser.new
		assert_equal parser.space?.parse(" ").to_s, " "
		assert_equal parser.space?.parse("").to_s, ""
	end

	test "letters" do
		parser = QTIParser.new
		a = parser.parse("aifjeovj")
		assert_equal "aifjeovj", QTITransform.new.apply(a)
		b = parser.parse("ei ief ")
		assert_equal "ei ief ", QTITransform.new.apply(b)
	end

	test "numbers" do
		parser = QTIParser.new
		a = parser.parse("4846473")
		assert_equal "4846473", QTITransform.new.apply(a)
		b = parser.parse("38 28 482 ")
		assert_equal "38 28 482 ", QTITransform.new.apply(b)
	end

	test "fslash" do
		parser = QTIParser.new
		a = parser.parse("/ ")
		assert_equal "/ ", QTITransform.new.apply(a)
		b = parser.parse("/")
		assert_equal "/", QTITransform.new.apply(b)
	end

	test "bslash" do
		parser = QTIParser.new
		a = parser.parse("\\ ")
		assert_equal "\\ ", QTITransform.new.apply(a)
		b = parser.parse("\\")
		assert_equal "\\", QTITransform.new.apply(b)
	end
	test "lparen" do
		parser = QTIParser.new
		a = parser.parse("( ")
		assert_equal "( ", QTITransform.new.apply(a)
		b = parser.parse("(")
		assert_equal "(", QTITransform.new.apply(b)
	end

	test "rparen" do
		parser = QTIParser.new
		a = parser.parse(") ")
		assert_equal ") ", QTITransform.new.apply(a)
		b = parser.parse(")")
		assert_equal ")", QTITransform.new.apply(b)
	end

	test "lbracket" do
		parser = QTIParser.new
		a = parser.parse("[ ")
		assert_equal "[ ", QTITransform.new.apply(a)
		b = parser.parse("[")
		assert_equal "[", QTITransform.new.apply(b)
	end

	test "rbracket" do
		parser = QTIParser.new
		a = parser.parse("] ")
		assert_equal "] ", QTITransform.new.apply(a)
		b = parser.parse("]")
		assert_equal "]", QTITransform.new.apply(b)
	end

	test "lthan" do
		parser = QTIParser.new
		a = parser.parse("< ")
		assert_equal "< ", QTITransform.new.apply(a)
		b = parser.parse("<")
		assert_equal "<", QTITransform.new.apply(b)
	end

	test "greaterthan" do
		parser = QTIParser.new
		a = parser.parse("> ")
		assert_equal "> ", QTITransform.new.apply(a)
		b = parser.parse(">")
		assert_equal ">", QTITransform.new.apply(b)
	end

	test "equal" do
		parser = QTIParser.new
		a = parser.parse("= ")
		assert_equal "= ", QTITransform.new.apply(a)
		b = parser.parse("=")
		assert_equal "=", QTITransform.new.apply(b)
	end

	test "hyphen" do
		parser = QTIParser.new
		a = parser.parse("- ")
		assert_equal "- ", QTITransform.new.apply(a)
		b = parser.parse("-")
		assert_equal "-", QTITransform.new.apply(b)
	end

	test "underscore" do
		parser = QTIParser.new
		a = parser.parse("_ ")
		assert_equal "_ ", QTITransform.new.apply(a)
		b = parser.parse("_")
		assert_equal "_", QTITransform.new.apply(b)
	end

	test "semicolon" do
		parser = QTIParser.new
		a = parser.parse("; ")
		assert_equal "; ", QTITransform.new.apply(a)
		b = parser.parse(";")
		assert_equal ";", QTITransform.new.apply(b)
	end

	test "colon" do
		parser = QTIParser.new
		a = parser.parse(": ")
		assert_equal ": ", QTITransform.new.apply(a)
		b = parser.parse(":")
		assert_equal ":", QTITransform.new.apply(b)
	end

	test "comma" do
		parser = QTIParser.new
		a = parser.parse(", ")
		assert_equal ", ", QTITransform.new.apply(a)
		b = parser.parse(",")
		assert_equal ",", QTITransform.new.apply(b)
	end

	test "period" do
		parser = QTIParser.new
		a = parser.parse(". ")
		assert_equal ". ", QTITransform.new.apply(a)
		b = parser.parse(".")
		assert_equal ".", QTITransform.new.apply(b)
	end

	test "qmark" do
		parser = QTIParser.new
		a = parser.parse("? ")
		assert_equal "? ", QTITransform.new.apply(a)
		b = parser.parse("?")
		assert_equal "?", QTITransform.new.apply(b)
	end

	test "exclamation" do
		parser = QTIParser.new
		a = parser.parse("! ")
		assert_equal "! ", QTITransform.new.apply(a)
		b = parser.parse("!")
		assert_equal "!", QTITransform.new.apply(b)
	end

	test "ampersand" do
		parser = QTIParser.new
		a = parser.parse("& ")
		assert_equal "& ", QTITransform.new.apply(a)
		b = parser.parse("&")
		assert_equal "&", QTITransform.new.apply(b)
	end

	test "percent" do
		parser = QTIParser.new
		a = parser.parse("% ")
		assert_equal "% ", QTITransform.new.apply(a)
		b = parser.parse("%")
		assert_equal "%", QTITransform.new.apply(b)
	end

	test "star" do
		parser = QTIParser.new
		a = parser.parse("* ")
		assert_equal "* ", QTITransform.new.apply(a)
		b = parser.parse("*")
		assert_equal "*", QTITransform.new.apply(b)
	end

	test "caret" do
		parser = QTIParser.new
		a = parser.parse("^ ")
		assert_equal "^ ", QTITransform.new.apply(a)
		b = parser.parse("^")
		assert_equal "^", QTITransform.new.apply(b)
	end

	test "quote" do
		parser = QTIParser.new
		a = parser.parse('" ')
		assert_equal '" ', QTITransform.new.apply(a)
		b = parser.parse('"')
		assert_equal '"', QTITransform.new.apply(b)
	end

	test "samples" do
		parser = QTIParser.new
		samples = Array.new
		samples [0] =  '<![CDATA[The meaning of "negative frequency" in a Fourier series 
 	                   is:]]>'
 	    samples [1] = '<![CDATA[What is the Phase Angle (<TT>&phi;</TT>) for the followi
 					  ng sinusoid where <PRE class=ITS_Equation>x(t) = cos(ωt + φ); 
 					  </PRE>]]>'
 		assert_nothing_raised(Parslet::ParseFailed) {parser.parse(samples[0])}
 		assert_nothing_raised(Parslet::ParseFailed) {parser.parse(samples[1])}
 	end

end