# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class QTImportTest < ActiveSupport::TestCase
	user = FactoryGirl.create(:user)

	test "1_question" do	
		assert_nothing_raised do
			document = QTImport.openfile("#{::Rails.root}/test/fixtures/files/spqr1.xml")
			project = QTImport.createproject(user)
			parser, transformer = QTImport.choose_import('SPQR')
			content = QTImport.iterate_items(document)
			questions = QTImport.get_questions(project,content,parser,transformer,user)
		end
	end

	test "2_question" do		
		assert_nothing_raised do
			document = QTImport.openfile("#{::Rails.root}/test/fixtures/files/spqr2.xml")
			project = QTImport.createproject(user)
			parser, transformer = QTImport.choose_import('SPQR')
			content = QTImport.iterate_items(document)
			questions = QTImport.get_questions(project,content,parser,transformer,user)
		end
	end

	test "5_question" do
		assert_nothing_raised do
			document = QTImport.openfile("#{::Rails.root}/test/fixtures/files/spqr3.xml")
			project = QTImport.createproject(user)
			parser, transformer = QTImport.choose_import('SPQR')
			content = QTImport.iterate_items(document)
			questions = QTImport.get_questions(project,content,parser,transformer,user)
		end
	end

	test "25_question" do
		assert_nothing_raised do
			document = QTImport.openfile("#{::Rails.root}/test/fixtures/files/spqr4.xml")
			project = QTImport.createproject(user)
			parser, transformer = QTImport.choose_import('SPQR')
			content = QTImport.iterate_items(document)
			questions = QTImport.get_questions(project,content,parser,transformer,user)
		end
	end

	test "all_question" do
		assert_nothing_raised do
			document = QTImport.openfile("#{::Rails.root}/test/fixtures/files/spqr_original.xml")
			project = QTImport.createproject(user)
			parser, transformer = QTImport.choose_import('SPQR')
			content = QTImport.iterate_items(document)
			questions = QTImport.get_questions(project,content,parser,transformer,user)
		end
	end
end
