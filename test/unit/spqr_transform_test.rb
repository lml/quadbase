#encoding: utf-8

# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'
require 'parslet/convenience'

class SPQRTransfromTest < ActiveSupport::TestCase
	#This array contains sample questions used for testing.
	samples = Array.new
	samples [0] = 'iejfei<img src="/ece2025/cgi-bin/mimetex.exe?\hat\omega"> blue'
	samples [1] = 'Determine the smallest <font color="darkgreen">integer</font> value of the sampling rate'


	 test "img_filename" do
	 	parser = SPQRParser.new
	 	a =  parser.name.parse('/ece2025/cgi-bin/mimetex.exe?\hat\om')
	 	expected = "{:filename=>\"/ece2025/cgi-bin/mimetex.exe?\\\\hat\\\\om\"@0}"
	 	assert_equal expected, a.to_s()
	 end

	 test "image_start_tag" do
	 	parser = SPQRParser.new
	 	a = parser.image_start_tag.parse('<img')
	 	expected =  "<img"
	 	assert_equal expected, a.to_s()
	 end


	 test "images" do 
	 	parser = SPQRParser.new
	 	a = parser.image.parse('<img src="/ece2025/cgi-bin/mimetex.exe?\hat\omega">')
	 	expected = "{:image=>[{:filename=>\"/ece2025/cgi-bin/mimetex.exe?\\\\hat\\\\omega\"@10}]}"
	 	assert_equal expected,a.to_s()	 	
	 end

	 test "text_w_images" do
	 	parser = SPQRParser.new
	 	a = parser.parse(samples[0])
	 	expected = "iejfeiMISSING IMAGE: /ece2025/cgi-bin/mimetex.exe?\\hat\\omega blue"
	 	output1 = SPQRTransform.new.apply(a)
	 	assert_equal expected, output1
	 end

	 test "italics" do
	 	parser = SPQRParser.new
	 	a = parser.parse('a<i>This is italics.</i>')
	 	expected = "a'This is italics.'"
	 	output1 = SPQRTransform.new.apply(a)
	 	assert_equal expected, output1
	 	b = parser.parse('a<I>This is italics.</I>')
	 	output2 = SPQRTransform.new.apply(b)
	 	assert_equal expected, output2
	 end

	 test "bold" do
	 	parser = SPQRParser.new
	 	a = parser.parse('a<b>This is bold text.</b>')
	 	expected = "a!!This is bold text.!!"
	 	output1 = SPQRTransform.new.apply(a)
	 	assert_equal expected, output1
	 	b = parser.parse('a<B>This is bold text.</B>')
	 	output2 = SPQRTransform.new.apply(b)
	 	assert_equal expected, output2
	 end

	 test "line_break" do
	 	parser = SPQRParser.new
	 	a = parser.parse('That was <br>unexpected.')
	 	expected = "That was \nunexpected."
	 	output1 = SPQRTransform.new.apply(a)
	 	assert_equal expected, output1
	 	b = parser.parse('That was <BR>unexpected.')
	 	output2 = SPQRTransform.new.apply(b)
	 	assert_equal expected, output2
	 end

	 test "teletype" do
	 	parser = SPQRParser.new
	 	a = parser.parse('a<tt>MATH111</tt>')
	 	expected = "a$MATH111$"
	 	output1 = SPQRTransform.new.apply(a)
	 	assert_equal expected, output1
	 	b = parser.parse('a<TT>MATH111</TT>')
	 	output2 = SPQRTransform.new.apply(b)
	 	assert_equal expected, output2
	 end

	 test "new_paragraph" do
	 	parser = SPQRParser.new
	 	a = parser.parse('That was <p>unexpected</p>.')
	 	expected = "That was \n\nunexpected\n\n."
	 	output1 = SPQRTransform.new.apply(a)
	 	assert_equal expected, output1
	 	b = parser.parse('That was <P>unexpected</P>.')
	 	output2 = SPQRTransform.new.apply(b)
	 	assert_equal expected, output2
	 end

	 test "font_open" do
	 	parser = SPQRParser.new
	 	a = parser.font_open.parse('<font color="blue">')
	 	expected = "<font color=\"blue\">"
	 	assert_equal expected, a.to_s
	 end

	 test "font_change" do
	 	parser = SPQRParser.new
	 	a = parser.font.parse('<font color="blue">blah</font>')
	 	expected = "{:font=>{:content_f=>[{:letters=>\"blah\"@19}]}}"
	 	assert_equal expected, a.to_s
	 end

	 test "font" do
	 	parser = SPQRParser.new
	 	a = parser.parse(samples[1])
	 	output1 = SPQRTransform.new.apply(a)
	 	expected = "Determine the smallest !!integer!! value of the sampling rate"
	 	assert_equal expected, output1
	 end

	 test "phi" do
	 	parser = SPQRParser.new
	 	a = parser.parse('&phi;')
	 	expected = "\phi"
	 	output1 = SPQRTransform.new.apply(a)
	 	assert_equal expected, output1
	 end

	 test "pi" do
	 	parser = SPQRParser.new
	 	a = parser.parse('a&pi;')
	 	expected = "a\pi"
	 	output1 = SPQRTransform.new.apply(a)
	 	assert_equal expected, output1
	 end

	 test "omega" do
	 	parser = SPQRParser.new
	 	a = parser.parse('a&omega;')
	 	expected = "a\omega"
	 	output1 = SPQRTransform.new.apply(a)
	 	assert_equal expected, output1
	 end

	 test "curly_f" do
	 	parser = SPQRParser.new
	 	a = parser.parse('&fnof;s')
	 	expected = "fs"
	 	output1 = SPQRTransform.new.apply(a)
	 	assert_equal expected, output1
	 end

	 test "sub" do
	 	parser = SPQRParser.new
	 	a = parser.parse('a<sub>&phi;</sub>')
	 	expected1 = "a_{phi}"
	 	output1 = SPQRTransform.new.apply(a)
	 	assert_equal expected1, output1
	 	b = parser.parse('a<SUB>eie</SUB>w')
	 	expected2 = "a_{eie}w"
	 	output2 = SPQRTransform.new.apply(b)
	 	assert_equal expected2, output2
	 end

	 test "sup" do
	 	parser = SPQRParser.new
	 	a = parser.parse('a<sup>&pi;</sup>')
	 	expected1 = "a^{\pi}"
	 	output1 = SPQRTransform.new.apply(a)
	 	assert_equal expected1, output1
	 	b = parser.parse('b<SUP>iefie</SUP>')
	 	expected2 = "b^{iefie}"
	 	output2 = SPQRTransform.new.apply(b)
	 	assert_equal expected2, output2
	 end

	 test "pre_class" do
	 	parser = SPQRParser.new
	 	a = parser.parse('a<pre class = "ITS_EQUATION">blah</PRE>more')
	 	expected = "a$$blah$$more"
	 	output1 = SPQRTransform.new.apply(a)
	 	assert_equal expected, output1
	 end

	 test "span" do
	 	parser = SPQRParser.new
	 	a = parser.parse('a<span class="comment">Uh, something.</span>more')
	 	expected = "aUh, something.more"
	 	output1 = SPQRTransform.new.apply(a)
	 	assert_equal expected, output1
	 end

	 test "div" do
	 	parser = SPQRParser.new
	 	a = parser.parse('a<div Size=4>Text!</DIV>')
	 	expected = "aText!"
	 	output1 = SPQRTransform.new.apply(a)
	 	assert_equal expected, output1
	 end

	 test "center" do
	 	parser = SPQRParser.new
	 	a = parser.parse('a<center>Image</CENTER>')
	 	expected = "aImage"
	 	output1 = SPQRTransform.new.apply(a)
	 	assert_equal expected, output1
	 end

	 test "2tags" do
	 	parser = SPQRParser.new
	 	a = parser.parse('a<span class="comment"><img src="filename.jpg"></span>')
	 	output1 = SPQRTransform.new.apply(a)
	 	expected = "aMISSING IMAGE: filename.jpg"
	 	assert_equal expected, output1
	 end

	 test "3tags" do
	 	parser = SPQRParser.new
	 	a = parser.parse('a<div class="four"><pre class="MATLAB"><i>&pi;</i></PRE></div>')
	 	expected = "a$$'\pi'$$"
	 	output1 = SPQRTransform.new.apply(a)
	 	assert_equal expected, output1
	 end
end