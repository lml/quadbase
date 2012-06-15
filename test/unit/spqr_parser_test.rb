#encoding: utf-8

# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'
require 'parslet/convenience'

class SPQRParserTest < ActiveSupport::TestCase

	test "space" do 
		parser = SPQRParser.new
		assert_equal parser.space.parse(" ").to_s, " "
	end

	test "space?" do
		parser = SPQRParser.new
		assert_equal parser.space?.parse(" ").to_s, " "
		assert_equal parser.space?.parse("").to_s, ""
	end

	test "letters" do
		parser = SPQRParser.new
		assert_nothing_raised(Parslet::ParseFailed) {parser.parse("aifjeovj")}
		assert_nothing_raised(Parslet::ParseFailed) {parser.parse("ei ief ")}
	end

	test "numbers" do
		parser = SPQRParser.new
		assert_nothing_raised(Parslet::ParseFailed) {parser.parse("484673")}
		assert_nothing_raised(Parslet::ParseFailed) {parser.parse("38 28 482")}
	end

	test "fslash" do
		parser = SPQRParser.new
		assert_nothing_raised(Parslet::ParseFailed) {parser.parse("/ ")}
		assert_nothing_raised(Parslet::ParseFailed) {parser.parse("/")}
	end

	test "bslash" do
		parser = SPQRParser.new
		assert_nothing_raised(Parslet::ParseFailed) {parser.parse("\\ ")}
		assert_nothing_raised(Parslet::ParseFailed) {parser.parse("\\")}
	end

	test "lparen" do
		parser = SPQRParser.new
		assert_nothing_raised(Parslet::ParseFailed) {parser.parse("( ")}
		assert_nothing_raised(Parslet::ParseFailed) {parser.parse("(")}
	end

	test "rparen" do
		parser = SPQRParser.new
		assert_nothing_raised(Parslet::ParseFailed) {parser.parse(") ")}
		assert_nothing_raised(Parslet::ParseFailed) {parser.parse(")")}
	end

	test "lbracket" do
		parser = SPQRParser.new
		assert_nothing_raised(Parslet::ParseFailed) {parser.parse("[ ")}
		assert_nothing_raised(Parslet::ParseFailed) {parser.parse("[")}
	end

	test "rbracket" do
		parser = SPQRParser.new
		assert_nothing_raised(Parslet::ParseFailed) {parser.parse("] ")}
		assert_nothing_raised(Parslet::ParseFailed) {parser.parse("]")}
	end

	test "greaterthan" do
		parser = SPQRParser.new
		assert_nothing_raised(Parslet::ParseFailed) {parser.parse("> ")}
		assert_nothing_raised(Parslet::ParseFailed) {parser.parse(">")}
	end

	test "equal" do
		parser = SPQRParser.new
		assert_nothing_raised(Parslet::ParseFailed) {parser.parse("= ")}
		assert_nothing_raised(Parslet::ParseFailed) {parser.parse("=")}
	end

	test "hyphen" do
		parser = SPQRParser.new
		assert_nothing_raised(Parslet::ParseFailed) {parser.parse("- ")}
		assert_nothing_raised(Parslet::ParseFailed) {parser.parse("-")}
	end

	test "underscore" do
		parser = SPQRParser.new
		assert_nothing_raised(Parslet::ParseFailed) {parser.parse("_ ")}
		assert_nothing_raised(Parslet::ParseFailed) {parser.parse("_")}
	end

	test "semicolon" do
		parser = SPQRParser.new
		assert_nothing_raised(Parslet::ParseFailed) {parser.parse("; ")}
		assert_nothing_raised(Parslet::ParseFailed) {parser.parse(";")}
	end

	test "colon" do
		parser = SPQRParser.new
		assert_nothing_raised(Parslet::ParseFailed) {parser.parse(": ")}
		assert_nothing_raised(Parslet::ParseFailed) {parser.parse(":")}
	end

	test "comma" do
		parser = SPQRParser.new
		assert_nothing_raised(Parslet::ParseFailed) {parser.parse(", ")}
		assert_nothing_raised(Parslet::ParseFailed) {parser.parse(",")}
	end

	test "period" do
		parser = SPQRParser.new
		assert_nothing_raised(Parslet::ParseFailed) {parser.parse(". ")}
		assert_nothing_raised(Parslet::ParseFailed) {parser.parse(".")}
	end

	test "qmark" do
		parser = SPQRParser.new
		assert_nothing_raised(Parslet::ParseFailed) {parser.parse("? ")}
		assert_nothing_raised(Parslet::ParseFailed) {parser.parse("?")}
	end

	test "exclamation" do
		parser = SPQRParser.new
		assert_nothing_raised(Parslet::ParseFailed) {parser.parse("! ")}
		assert_nothing_raised(Parslet::ParseFailed) {parser.parse("!")}
	end

	test "ampersand" do
		parser = SPQRParser.new
		assert_nothing_raised(Parslet::ParseFailed) {parser.parse("& ")}
		assert_nothing_raised(Parslet::ParseFailed) {parser.parse("&")}
	end

	test "percent" do
		parser = SPQRParser.new
		assert_nothing_raised(Parslet::ParseFailed) {parser.parse("% ")}
		assert_nothing_raised(Parslet::ParseFailed) {parser.parse("%")}
	end

	test "star" do
		parser = SPQRParser.new
		assert_nothing_raised(Parslet::ParseFailed) {parser.parse("* ")}
		assert_nothing_raised(Parslet::ParseFailed) {parser.parse("*")}
	end

	test "caret" do
		parser = SPQRParser.new
		assert_nothing_raised(Parslet::ParseFailed) {parser.parse("^ ")}
		assert_nothing_raised(Parslet::ParseFailed) {parser.parse("^")}
	end

	test "quote" do
		parser = SPQRParser.new
		assert_nothing_raised(Parslet::ParseFailed) {parser.parse('" ')}
		assert_nothing_raised(Parslet::ParseFailed) {parser.parse('"')}
	end

	test "samples" do
		parser = SPQRParser.new
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