# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class QTImportTest < ActiveSupport::TestCase
	test "1_question" do	
		assert_nothing_raised do
			document = QTImport.openfile("#{::Rails.root}/test/fixtures/files/spqr1.xml")
			parser, transformer = QTImport.choose_import('SPQR')
			content = QTImport.iterate_items(document)
			questions = QTImport.get_questions(content,parser,transformer)
			project = QTImport.createproject
			QTImport.add_questions(project,questions)
		end
	end

	test "2_question" do		
		assert_nothing_raised do
			document = QTImport.openfile("#{::Rails.root}/test/fixtures/files/spqr2.xml")
			parser, transformer = QTImport.choose_import('SPQR')
			content = QTImport.iterate_items(document)
			questions = QTImport.get_questions(content,parser,transformer)
			project = QTImport.createproject
			QTImport.add_questions(project,questions)
		end
	end

	test "5_question" do
		assert_nothing_raised do
			document = QTImport.openfile("#{::Rails.root}/test/fixtures/files/spqr3.xml")
			parser, transformer = QTImport.choose_import('SPQR')
			content = QTImport.iterate_items(document)
			questions = QTImport.get_questions(content,parser,transformer)
			project = QTImport.createproject
			QTImport.add_questions(project,questions)
		end
	end

	test "25_question" do
		assert_nothing_raised do
			document = QTImport.openfile("#{::Rails.root}/test/fixtures/files/spqr4.xml")
			parser, transformer = QTImport.choose_import('SPQR')
			content = QTImport.iterate_items(document)
			questions = QTImport.get_questions(content,parser,transformer)
			project = QTImport.createproject
			QTImport.add_questions(project,questions)
		end
	end

	test "all_question" do
		assert_nothing_raised do
			document = QTImport.openfile("#{::Rails.root}/test/fixtures/files/spqr_original.xml")
			parser, transformer = QTImport.choose_import('SPQR')
			content = QTImport.iterate_items(document)
			questions = QTImport.get_questions(content,parser,transformer)
			project = QTImport.createproject
			QTImport.add_questions(project,questions)
		end
	end
end
