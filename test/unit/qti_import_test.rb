# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class QTImportTest < ActiveSupport::TestCase

	setup do
		@user = FactoryGirl.create(:user)
	end

	test "1_question" do	
		assert_nothing_raised do
			document = QTImport.openfile("#{::Rails.root}/test/fixtures/files/spqr1.xml")
			project = QTImport.createproject(@user)
			parser, transformer = QTImport.choose_import('SPQR')
			content = QTImport.iterate_items(document)
			QTImport.get_questions(project,content,parser,transformer,@user)
		end
	end

	test "1_question_w_images" do
		assert_nothing_raised do
			a, images = QTImport.unzip("#{::Rails.root}/test/fixtures/files/ITS_Q853.zip","#{Rails.root}/tmp/import")
			document = QTImport.openfile(a.path)
			project = QTImport.createproject(@user)
			parser, transformer = QTImport.choose_import('SPQR')
			content = QTImport.iterate_items(document)
			QTImport.get_questions(project,content,parser,transformer,@user,images)
		end
	end

	test "2_question" do		
		assert_nothing_raised do
			document = QTImport.openfile("#{::Rails.root}/test/fixtures/files/spqr2.xml")
			project = QTImport.createproject(@user)
			parser, transformer = QTImport.choose_import('SPQR')
			content = QTImport.iterate_items(document)
			questions = QTImport.get_questions(project,content,parser,transformer,@user)
		end
	end

	test "5_question" do
		assert_nothing_raised do
			document = QTImport.openfile("#{::Rails.root}/test/fixtures/files/spqr3.xml")
			project = QTImport.createproject(@user)
			parser, transformer = QTImport.choose_import('SPQR')
			content = QTImport.iterate_items(document)
			questions = QTImport.get_questions(project,content,parser,transformer,@user)
		end
	end
end
