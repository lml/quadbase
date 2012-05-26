#encoding: utf-8

# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'
require 'parslet/convenience'

class QTITransfromTest < ActiveSupport::TestCase
	#This array contains sample questions used for testing.
	samples = Array.new
	samples [0] = 'iejfei<img src="/ece2025/cgi-bin/mimetex.exe?\hat\om
	 ega"> (blue to red), '

	 test "img_filename" do
	 	parser = QTIParser.new
	 	a =  parser.filename.parse('/ece2025/cgi-bin/mimetex.exe?\hat\om')
	 	expected = "{:filename=>\"/ece2025/cgi-bin/mimetex.exe?\\\\hat\\\\om\"@0}"
	 	assert_equal expected, a.to_s()
	 end

	 test "image_start_tag" do
	 	parser = QTIParser.new
	 	a = parser.image_start_tag.parse('<img src="')
	 	expected =  "<img src=\""
	 	assert_equal expected, a.to_s()
	 end


	 test "images" do 
	 	parser = QTIParser.new
	 	a = parser.image.parse('<img src="/ece2025/cgi-bin/mimetex.exe?\hat\omega">')
	 	expected1 = "{:image=>[{:image_start_tag=>\"<img src=\\\"\"@0}, {:filename=>\"/ece2025/cgi-bin/mimetex.exe?\\\\hat\\\\omega\"@10}, {:image_end_tag=>\"\\\">\"@49}]}"
	 	assert_equal expected1,a.to_s()
	 	#assert_raise(Parslet::ParseFailed) {parser.parse(samples[0])}
	 end

	 test "text_w_images" do
	 	parser = QTIParser.new
	 	a = parser.parse(samples[0])	 
	 end

	 test "italics" do
	 	parser = QTIParser.new
	 	a = parser.parse('a<i>This is italics.</i>')
	 	expected1 = "a'This is italics.'"
	 	output1 = QTITransform.new.apply(a)
	 	assert_equal expected1, output1
	 	b = parser.parse('a<I>This is italics.</I>')
	 	expected2 = "a'This is italics.'"
	 	output2 = QTITransform.new.apply(b)
	 	assert_equal expected2, output2
	 end

	 test "bold" do
	 	parser = QTIParser.new
	 	a = parser.parse('a<b>This is bold text.</b>')
	 	expected1 = "a!!This is bold text.!!"
	 	output1 = QTITransform.new.apply(a)
	 	assert_equal expected1, output1
	 	b = parser.parse('a<B>This is bold text.</B>')
	 	expected2 = "a!!This is bold text.!!"
	 	output2 = QTITransform.new.apply(b)
	 	assert_equal expected2, output2
	 end

	 test "line_break" do
	 	parser = QTIParser.new
	 	a = parser.parse('aThat was <br>unexpected.')
	 	expected1 = "aThat was \nunexpected."
	 	output1 = QTITransform.new.apply(a)
	 	assert_equal expected1, output1
	 	b = parser.parse('aThat was <BR>unexpected.')
	 	expected2 = "aThat was \nunexpected."
	 	output2 = QTITransform.new.apply(b)
	 	assert_equal expected2, output2
	 end
end