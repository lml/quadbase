# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class QTImportTest < ActiveSupport::TestCase
	test "1_question" do	
		assert_nothing_raised do
			QTImport.new("#{::Rails.root}/test/fixtures/files/spqr1.xml",'SPQR')
		end
	end

	test "2_question" do		
		assert_nothing_raised do
			QTImport.new("#{::Rails.root}/test/fixtures/files/spqr2.xml",'SPQR')
		end
	end

	test "5_question" do
		assert_nothing_raised do
			QTImport.new("#{::Rails.root}/test/fixtures/files/spqr3.xml",'SPQR')
		end
	end

	test "25_question" do
		assert_nothing_raised do
			QTImport.new("#{::Rails.root}/test/fixtures/files/spqr4.xml",'SPQR')
		end
	end

	test "all_question" do
		assert_nothing_raised do
			QTImport.new("#{::Rails.root}/test/fixtures/files/spqr_original.xml",'SPQR')
		end
	end
end
