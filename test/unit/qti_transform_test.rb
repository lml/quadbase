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
	samples [1] = 'Determine the smallest <font color="darkgreen">integer</font> 
	value of the sampling rate'


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
	 	expected1 = "{:image=>[{:filename=>\"/ece2025/cgi-bin/mimetex.exe?\\\\hat\\\\omega\"@10}]}"
	 	assert_equal expected1,a.to_s()	 	
	 end

	 test "text_w_images" do
	 	parser = QTIParser.new
	 	a = parser.parse(samples[0])
	 	assert_raise(UnavailableImage) {QTITransform.new.apply(a)}
	 end

	 test "italics" do
	 	parser = QTIParser.new
	 	a = parser.parse('a<i>This is italics.</i>')
	 	expected = "a'This is italics.'"
	 	output1 = QTITransform.new.apply(a)
	 	assert_equal expected, output1
	 	b = parser.parse('a<I>This is italics.</I>')
	 	output2 = QTITransform.new.apply(b)
	 	assert_equal expected, output2
	 end

	 test "bold" do
	 	parser = QTIParser.new
	 	a = parser.parse('a<b>This is bold text.</b>')
	 	expected = "a!!This is bold text.!!"
	 	output1 = QTITransform.new.apply(a)
	 	assert_equal expected, output1
	 	b = parser.parse('a<B>This is bold text.</B>')
	 	output2 = QTITransform.new.apply(b)
	 	assert_equal expected, output2
	 end

	 test "line_break" do
	 	parser = QTIParser.new
	 	a = parser.parse('That was <br>unexpected.')
	 	expected = "That was \nunexpected."
	 	output1 = QTITransform.new.apply(a)
	 	assert_equal expected, output1
	 	b = parser.parse('That was <BR>unexpected.')
	 	output2 = QTITransform.new.apply(b)
	 	assert_equal expected, output2
	 end

	 test "teletype" do
	 	parser = QTIParser.new
	 	a = parser.parse('a<tt>MATH111</tt>')
	 	expected = "a$MATH111$"
	 	output1 = QTITransform.new.apply(a)
	 	assert_equal expected, output1
	 	b = parser.parse('a<TT>MATH111</TT>')
	 	output2 = QTITransform.new.apply(b)
	 	assert_equal expected, output2
	 end

	 test "new_paragraph" do
	 	parser = QTIParser.new
	 	a = parser.parse('That was <p>unexpected</p>.')
	 	expected = "That was \n\nunexpected\n\n."
	 	output1 = QTITransform.new.apply(a)
	 	assert_equal expected, output1
	 	b = parser.parse('That was <P>unexpected</P>.')
	 	output2 = QTITransform.new.apply(b)
	 	assert_equal expected, output2
	 end

	 test "font_open" do
	 	parser = QTIParser.new
	 	a = parser.font_open.parse('<font color="blue">')
	 	expected = "<font color=\"blue\">"
	 	assert_equal expected, a.to_s
	 end

	 test "font_change" do
	 	parser = QTIParser.new
	 	a = parser.font.parse('<font color="blue">blah</font>')
	 	expected = "{:font=>[{:content_f=>\"blah\"@19}]}"
	 	assert_equal expected, a.to_s
	 end

	 test "font" do
	 	parser = QTIParser.new
	 	a = parser.parse(samples[1])
	 	output1 = QTITransform.new.apply(a)
	 	expected = "Determine the smallest !!integer!! \n\tvalue of the sampling rate"
	 	assert_equal expected, output1
	 end

	 test "pre_class" do
	 	parser = QTIParser.new
	 	a = parser.parse('a<pre class = "ITS_EQUATION">blah</PRE>')
	 	p a
	 end

end