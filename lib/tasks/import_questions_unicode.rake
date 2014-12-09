# Copyright 2014 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

# Imports a unicode tab-delimited txt file saved from Excel
# Arguments are, in order:
# filename, Author/CR holder user's id, skip_first_row,
# column separator and row separator
# Example: rake questions:import:unicode[questions.txt,1]
#          will import questions from questions.txt and
#          assign the user with ID 1 as the author,
#          CR holder and solution author

require 'csv'

def clean(text)
  return nil if text.nil?
  text.gsub(/[\u201C\u201D\u201E\u201F\u2033\u2036]/, '"')
      .gsub(/[\u2018\u2019\u201A\u201B\u2032\u2035]/, "'")
      .gsub(/\r-\s/, "\n* ").gsub(/\r[\d]+\.\s/, "\n# ").strip
end

namespace :questions do
  namespace :import do
    task :unicode, [:filename, :user_id, :skip_first_row,
                    :col_sep, :row_sep] => :environment do |t, args|
      filename = args[:filename] || 'questions.txt'

      puts "Reading from #{filename}"

      user = User.find(args[:user_id])

      puts "Setting #{user.full_name} as Author and Copyright Holder"

      skip_first_row = args[:skip_first_row].nil? ? \
                         true : args[:skip_first_row]
      content = File.read(filename)
      encoding = CharlockHolmes::EncodingDetector.detect(content)[:encoding]
      options = {:encoding => encoding,
                 :col_sep => args[:col_sep] || "\t",
                 :row_sep => args[:row_sep] || "\r\n"}

      puts 'Importing questions. Please wait...'

      i = 0
      SimpleQuestion.transaction do
        CSV.foreach(filename, options) do |row|
          i += 1
          next if i == 1 && skip_first_row

          book = clean(row[0])
          type_tag = clean(row[1].downcase)
          subject = clean(row[2].downcase)
          chapter_section = clean(row[3].gsub('.', '-'))
          chapter_tag = "#{subject} #{chapter_section}"
          content_tags = (row[4] || '').downcase.gsub('.', ',').split(',')
                                                .collect { |r| clean(r) }
          tags = [book, chapter_tag, content_tags, type_tag].flatten
          list_name = clean(row[5])
          content = clean(row[6])
          explanation = clean(row[7])
          #free_response = row[8].downcase.strip == 'yes'
          correct_answer_index = row[9].downcase.strip.each_byte.first - 97
          answers = row[10..-1].collect{|a| clean(a)}

          q = SimpleQuestion.new
          q.content = content
          q.tag_list.add(*tags)
          q.save!
          q.reload

          qc = QuestionCollaborator.new
          qc.question = q
          qc.user = user
          qc.is_author = true
          qc.is_copyright_holder = true
          qc.save!

          answers.each_with_index do |a, j|
            next if a.blank?
            ac = AnswerChoice.new
            ac.question = q
            ac.content = a
            ac.credit = j == correct_answer_index ? 1 : 0
            ac.save!
          end

          s = Solution.new
          s.question = q
          s.content = explanation
          s.creator = user
          s.save!

          list = List.where(:name => list_name).first
          if list.nil?
            puts "Creating new list #{list_name}"
            list = List.create(:name => list_name)
            lm = ListMember.new
            lm.user = user
            lm.list = list
            lm.save
          end

          lq = ListQuestion.new
          lq.question = q
          lq.list = list
          lq.save!
        end

        puts "Created #{skip_first_row ? i-1 : i} question(s)."
      end
    end
  end
end
