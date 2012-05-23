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
		assert_equal parser.letters.parse("aifjeovj").to_s, "aifjeovj"
		assert_equal parser.letters.parse("ei ief ").to_s, "ei ief "
	end

	test "numbers" do
		parser = QTIParser.new
		assert_equal parser.letters.parse("4846473").to_s, "4846473"
		assert_equal parser.letters.parse("38 28 482 ").to_s, "38 28 482 "
	end

	test "fslash" do
		parser = QTIParser.new
		assert_equal parser.any.parse("/ ").to_s, "/ "
		assert_equal parser.any.parse("/").to_s, "/"
	end

	test "bslash" do
		parser = QTIParser.new
		assert_equal parser.any.parse("\\ ").to_s, "\\ "
		assert_equal parser.any.parse("\\").to_s, "\\"
	end

	test "lparen" do
		parser = QTIParser.new
		assert_equal parser.any.parse("( ").to_s, "( "
		assert_equal parser.any.parse("(").to_s, "("
	end

	test "rparen" do
		parser = QTIParser.new
		assert_equal parser.any.parse(") ").to_s, ") "
		assert_equal parser.any.parse(")").to_s, ")"
	end

	test "lbracket" do
		parser = QTIParser.new
		assert_equal parser.any.parse("[ ").to_s, "[ "
		assert_equal parser.any.parse("[").to_s, "["
	end

	test "rbracket" do
		parser = QTIParser.new
		assert_equal parser.any.parse("] ").to_s, "] "
		assert_equal parser.any.parse("]").to_s, "]"
	end

	test "lthan" do
		parser = QTIParser.new
		assert_equal parser.any.parse("< ").to_s, "< "
		assert_equal parser.any.parse("<").to_s, "<"
	end

	test "greaterthan" do
		parser = QTIParser.new
		assert_equal parser.any.parse("> ").to_s, "> "
		assert_equal parser.any.parse(">").to_s, ">"
	end

	test "equal" do
		parser = QTIParser.new
		assert_equal parser.any.parse("= ").to_s, "= "
		assert_equal parser.any.parse("=").to_s, "="
	end

	test "hyphen" do
		parser = QTIParser.new
		assert_equal parser.any.parse("- ").to_s, "- "
		assert_equal parser.any.parse("-").to_s, "-"
	end

	test "underscore" do
		parser = QTIParser.new
		assert_equal parser.letters.parse("_ ").to_s, "_ "
		assert_equal parser.letters.parse("_").to_s, "_"
	end

	test "semicolon" do
		parser = QTIParser.new
		assert_equal parser.any.parse("; ").to_s, "; "
		assert_equal parser.any.parse(";").to_s, ";"
	end

	test "colon" do
		parser = QTIParser.new
		assert_equal parser.any.parse(": ").to_s, ": "
		assert_equal parser.any.parse(":").to_s, ":"
	end

	test "comma" do
		parser = QTIParser.new
		assert_equal parser.any.parse(", ").to_s, ", "
		assert_equal parser.any.parse(",").to_s, ","
	end

	test "period" do
		parser = QTIParser.new
		assert_equal parser.any.parse(". ").to_s, ". "
		assert_equal parser.any.parse(".").to_s, "."
	end

	test "qmark" do
		parser = QTIParser.new
		assert_equal parser.any.parse("? ").to_s, "? "
		assert_equal parser.any.parse("?").to_s, "?"
	end

	test "exclamation" do
		parser = QTIParser.new
		assert_equal parser.any.parse("! ").to_s, "! "
		assert_equal parser.any.parse("!").to_s, "!"
	end

	test "ampersand" do
		parser = QTIParser.new
		assert_equal parser.any.parse("& ").to_s, "& "
		assert_equal parser.any.parse("&").to_s, "&"
	end

	test "percent" do
		parser = QTIParser.new
		assert_equal parser.any.parse("% ").to_s, "% "
		assert_equal parser.any.parse("%").to_s, "%"
	end

	test "star" do
		parser = QTIParser.new
		assert_equal parser.any.parse("* ").to_s, "* "
		assert_equal parser.any.parse("*").to_s, "*"
	end

	test "caret" do
		parser = QTIParser.new
		assert_equal parser.any.parse("^ ").to_s, "^ "
		assert_equal parser.any.parse("^").to_s, "^"
	end

	test "quote" do
		parser = QTIParser.new
		assert_equal parser.any.parse('" ').to_s, '" '
		assert_equal parser.any.parse('"').to_s, '"'
	end

	test "samples" do
		parser = QTIParser.new
		samples = Array.new
		samples [0] =  '<![CDATA[The meaning of "negative frequency" in a Fourier series 
 	                   is:]]>'
 	    samples [1] = '<![CDATA[What is the Phase Angle (<TT>&phi;</TT>) for the followi
 					  ng sinusoid where <PRE class=ITS_Equation>x(t) = cos(ωt + φ); 
 					  </PRE>]]>'
 		assert_nothing_raised(Parslet::ParseFailed) {parser.expression.parse(samples[0])}
 		assert_nothing_raised(Parslet::ParseFailed) {parser.expression.parse(samples[1])}
 	end

end