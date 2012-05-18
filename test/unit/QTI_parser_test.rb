# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'
require 'parslet/convenience'

class QTIParserTest < ActiveSupport::TestCase
	def setup
		@parser = QuestionParser.new
	end

	test "leftbracket" do
		parser = QuestionParser.new
		assert_equal parser.leftbracket.parse("[").to_s, "["
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
end