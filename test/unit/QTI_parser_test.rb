#encoding: utf-8

# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'
require 'parslet/convenience'

#Sample questions used in test
samples = Array.new
samples[0] = '<![CDATA[Given:<BR><BR><B><TT>fs = 11025;<BR>tt = (0:round(0.25*fs
	))/fs;</TT></B><BR><BR>Which MATLAB code would you use to gene
rate the appropriate DTMF signal to represent telephone key number
 <B>5</B>? And this is another way.]]>'

 samples[1] = '<![CDATA[The meaning of "negative frequency" in a Fourier series 
 	is:]]>'

 samples[2] = '<![CDATA[Refer to the following function, which is similar to the
  one used in lab 4:<p><tt>function tone=note(keynum,dur)</tt><br><tt>% Returns 
  a single sinusoid with the key and duration specified</tt><br><tt>fs = 11025;
  </tt><br><tt>tt = 0:1/fs:dur;</tt><br><tt>f0 = 440*2^((keynum-49)/12);</tt><br>
  <tt>tone = cos(2*pi*f0*tt);</tt><p>A student wants to modify the function so 
  that the tone created by this function has TWO frequency components. The new tone
   should be the sum of two sinusoids, one of which is the fundamental and the 
   other of which has a frequency 2 times higher. The amplitudes (and phases) can 
   be the same. Which one of the following is a correct modification that will 
   accomplish this task?]]>'

samples[3] = '<![CDATA[Below is the spectrum for the the signal <pre 
  class="ITS_Equation">x(t) = e<sup>2</sup><b>cos(</b>5&pi;t<b>)cos(</b>2&pi;f<sub>
  	c</sub>t<b>)</b></pre>Determine <tt>f<sub>c</sub></tt>.]]>'

samples[4] = '<![CDATA[Set the input frequency to <tt>&fnof;<sub>0</sub> = 13.4</tt> 
Hz. Determine the smallest <font color="darkgreen">integer</font> value of the sampling 
rate <tt>&fnof;s</tt> so that no aliasing occurs.  The units of <tt>&fnof;<sub>s</sub>
</tt> are samples per second.  You must justify your response by citing a theorem or 
property about sampling.]]>'

samples[5] = '<![CDATA[<i>Folded Alias:</i> Set the input frequency to <tt>&fnof;<sub>0</sub>
 = 13</tt> Hz, the input phase to <tt>&phi; = -1.3</tt> rads, and <tt>&fnof;<sub>s</sub> = 
 20</tt> Hz. Write down the formula for the output signal, and then write a justification 
 consisting of three steps:<OL><LI>calculating the values of <img src="/ece2025/cgi-bin/mimetex.
 exe?\hat\omega"> for the blue spectral lines in the spectrum of the discrete-time signal <tt>x
 [n]</tt> shown in the middle plots,<LI>aliasing <img src="/ece2025/cgi-bin/mimetex.exe?\hat\omega">
  (blue to red), and<LI>transforming <tt>x[n]</tt> into <tt>y(t)</tt> using an equation that 
  describes the ideal D-to-C converter and uses the <i>principal aias</i>.</OL> ]]>'

samples[6] = ' <![CDATA[What is the Phase Angle (<TT>&phi;</TT>) for the following sinusoid 
where <PRE class=ITS_Equation>x(t) = cos(ωt + φ); </PRE>]]>'


class QTIParserTest < ActiveSupport::TestCase
	def setup
		@parser = QuestionParser.new
	end

	test "space" do 
		parser = QuestionParser.new
		assert_equal parser.space.parse(" ").to_s, " "
	end

	test "space?" do
		parser = QuestionParser.new
		assert_equal parser.space?.parse(" ").to_s, " "
		assert_equal parser.space?.parse("").to_s, ""
	end

	test "fslash" do
		parser = QuestionParser.new
		assert_equal parser.fslash.parse("/ ").to_s, "/ "
		assert_equal parser.fslash.parse("/").to_s, "/"
	end

	test "lessthan" do
		parser = QuestionParser.new
		assert_equal parser.lessthan.parse("< ").to_s, "< "
		assert_equal parser.lessthan.parse("<").to_s, "<"
	end

	test "greaterthan" do
		parser = QuestionParser.new
		assert_equal parser.greaterthan.parse("> ").to_s, "> "
		assert_equal parser.greaterthan.parse(">").to_s,">"
	end

	test "equal" do
		parser = QuestionParser.new
		assert_equal parser.equal.parse("= ").to_s, "= "
		assert_equal parser.equal.parse("=").to_s, "= "
	end

	test "underscore" do
		parser = QuestionParser.new
		assert_equal parser.underscore.parse("_ ").to_s,"_ "
		assert_equal parser.underscore.parse("_").to_s,"_"
	end

	test "exclamation" do
		parser = QuestionParser.new
		assert_equal parser.exclamation.parse("! ").to_s, "! "
		assert_equal parser.exclamation.parse("!").to_s, "!"
	end

	test "leftbracket" do
		parser = QuestionParser.new
		assert_equal parser.leftbracket.parse("[ ").to_s, "[ "
		assert_equal parser.leftbracket.parse("[").to_s, "["
	end

	test "colon" do
		parser = QuestionParser.new
		assert_equal parser.colon.parse(": ").to_s, ": "
		assert_equal parser.colon.parse(":").to_s, ":"
	end

	test "semicolon" do
		parser = QuestionParser.new
		assert_equal parser.semicolon.parse("; ").to_s, "; "
		assert_equal parser.semicolon.parse(";").to_s, ";"
	end

	test "lparen" do
		parser = QuestionParser.new
		assert_equal parser.lparen.parse("( ").to_s, "( "
		assert_equal parser.lparen.parse("(").to_s, "("
	end

	test "rparen" do
		parser = QuestionParser.new
		assert_equal parser.rparen.parse(") ").to_s, ") "
		assert_equal parser.rparen.parse(")").to_s, ")"
	end

	test "period" do
		parser = QuestionParser.new
		assert_equal parser.period.parse(". ").to_s, ". "
		assert_equal parser.period.parse(".").to_s, "."
	end

	test "star" do
		parser = QuestionParser.new
		assert_equal parser.star.parse("* ").to_s, "* "
		assert_equal parser.star.parse("*").to_s, "*"
	end

	test "qmark" do
		parser = QuestionParser.new
		assert_equal parser.qmark.parse("? ").to_s, "? "
		assert_equal parser.qmark.parse("?").to_s, "?"
	end

	test "quote" do
		parser = QuestionParser.new
		assert_equal parser.quote.parse('" ').to_s, '" '
		assert_equal parser.quote.parse('"').to_s, '"'
	end

	test "ampersand" do
		parser = QuestionParser.new
		assert_equal parser.ampersand.parse("& ").to_s, "& "
		assert_equal parser.ampersand.parse("&").to_s, "&"
	end

	test "comma" do
		parser = QuestionParser.new
		assert_equal parser.comma.parse(", ").to_s, ", "
		assert_equal parser.comma.parse(",").to_s, ","
	end

	test "percent" do
		parser = QuestionParser.new
		assert_equal parser.percent.parse("% ").to_s, "% "
		assert_equal parser.percent.parse("%").to_s, "%"
	end

	test "caret" do
		parser = QuestionParser.new
		assert_equal parser.caret.parse("^ ").to_s, "^ "
		assert_equal parser.caret.parse("^").to_s, "^"
	end

	test "hyphen" do
		parser = QuestionParser.new
		assert_equal parser.hyphen.parse("- ").to_s, "- "
		assert_equal parser.hyphen.parse("-").to_s, "-"
	end

	test "bslash" do
		parser = QuestionParser.new
		assert_equal parser.bslash.parse("\\ ").to_s, "\\ "
		assert_equal parser.bslash.parse("\\").to_s, "\\"
	end

	test "samples" do
		for i in 0..(samples.length - 2) do
			parser = QuestionParser.new
			assert_equal parser.samples.parse(samples[i]).to_s, samples[i]
		end

		parser = QuestionParser.new
		assert_raise(Parslet::ParseFailed) {parser.samples.parse(samples[6])}
	end
end