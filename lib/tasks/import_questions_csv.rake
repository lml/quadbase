# Copyright 2014 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

# Imports a csv spreadsheet
# Arguments are, in order:
# filename, Author/CR holder user's id, skip_first_row,
# column separator and row separator
# Example: rake questions:import:csv[questions.csv,1]
#          will import questions from questions.csv and
#          assign the user with ID 1 as the author,
#          CR holder and solution author

require 'csv'

namespace :questions do
  namespace :import do
    task :csv, [:filename, :user_id, :skip_first_row,
                :col_sep, :row_sep] => :environment do |t, args|
      filename = args[:filename] || 'questions.csv'
      user = User.where(:id => args[:user_id]).first
      skip_first_row = args[:skip_first_row].nil? ? \
                         true : args[:skip_first_row]
      options = {:col_sep => args[:col_sep] || ',',
                 :row_sep => args[:row_sep] || "\n"}

      puts 'Importing questions. Please wait...'
      i = 0
      SimpleQuestion.transaction do
        CSV.foreach(filename, options) do |row|
          i += 1
          next if i == 1 && skip_first_row

          #chapter = row[0]
          #chapter_section = row[1]
          tags = row[2].split(' ')
          list_name = row[3]
          content = row[4]
          explanation = row[5]
          #free_response = row[6].downcase == 'yes'
          correct_answer_index = row[7].each_byte.first - 97
          answers = row[8..-1]

          q = SimpleQuestion.new
          q.content = content
          q.tag_list.add(*tags)
          q.save!
          q.reload

          unless user.nil?
            qc = QuestionCollaborator.new
            qc.question = q
            qc.user = user
            qc.is_author = true
            qc.is_copyright_holder = true
            qc.save!
          end

          answers.each_with_index do |a, j|
            next if a.nil?
            ac = AnswerChoice.new
            ac.question = q
            ac.content = a
            ac.credit = j == correct_answer_index ? 1 : 0
            ac.save!
          end

          unless user.nil?
            s = Solution.new
            s.question = q
            s.content = explanation
            s.creator = user
            s.save!
          end

          lq = ListQuestion.new
          lq.question = q
          lq.list = List.where(:name => list_name).first
          lq.save!
        end

        puts "Created #{skip_first_row ? i-1 : i} question(s)."
      end
    end
  end
end
