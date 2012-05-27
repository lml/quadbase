# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class QTImportTest < ActiveSupport::TestCase
	test "1_question" do
		import = QTImport.new('/home/railsoer/Documents/spqr1.xml','SPQR')
		assert_nothing_raised(import)
	end

	test "2_question" do
		import = QTImport.new('home/railsoer/Documents/spqr2.xml','SPQR')
		assert_nothing_raised(import)
	end

	test "5_question" do
		import = QTImport.new('home/railsoer/Documents/spqr3.xml','SPQR')
		assert_nothing_raised(import)
	end

	test "25_question" do
		import = QTImport.new('home/railsoer/Documents/spqr4.xml','SPQR')
		assert_nothing_raised(import)
	end

	test "all_question" do
		import = QTImport.new('home/railsoer/Documents/spqr_original.xml','SPQR')
		assert_nothing_raised(import)
	end
end
