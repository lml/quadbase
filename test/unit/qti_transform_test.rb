#encoding: utf-8

# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'
require 'parslet/convenience'

class QTITransfromTest < ActiveSupport::TestCase
	#This array contains sample questions used for testing.
	samples = Array.new
	samples [0] = '<img src="/ece2025/cgi-bin/mimetex.exe?\hat\om
	 ega"> (blue to red), '

	 test "images" do 
	 	parser = QTIParser.new
	 	#p parser.expression.parse('if')
	 	#assert_raise(Parslet::ParseFailed) {parser.parse(samples[0])}
	 end

	 test "italics" do
	 	parser = QTIParser.new
	 	a = parser.expression.parse('<i>This is italics.</i>')	
	 	expected = "'This is italics.'"
	 	output1 = QTITransform.new.apply(a)
	 	assert_equal expected, output1
	 end

	 	
end