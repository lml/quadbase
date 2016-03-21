# Copyright 2014 Rice University. Licensed under the Affero General Public
# License version 3 or later.  See the COPYRIGHT file for details.

# http://stackoverflow.com/a/2624395
namespace :questions do
  namespace :export do
    task :xlsx, [:filename, :user_id] => :environment do |t, args|
      filename = args[:filename] || 'questions.xlsx'
      puts 'Exporting questions. Please wait...'
      user_id = args[:user_id]
      questions = user_id.nil? ? \
                    Question.unscoped : \
                    Question.joins{[question_collaborators.outer,
                                    list_questions.outer.list.outer.list_members.outer]}
                            .where{(question_collaborators.user_id == user_id) | \
                                   (list_questions.list.list_members.user_id == user_id)}

      questions = questions.includes(:taggings => :tag)
                           .includes(:list_questions => :list)
                           .includes(:solutions).uniq.to_a

      Axlsx::Package.new do |p|
        p.workbook.add_worksheet(:name => 'Questions') do |s|
          s.add_row ['Tags (unordered)', 'List Name', 'Content',
                     'Explanation', 'Works with Free Response?',
                     'Correct Answer', 'Answers (until the end of the row)']

          questions.each do |question|
            tags = question.tags.collect{|t| t.name}.join(",")
            list_name = question.list_questions.first.list.try(:name) || ''
            content = question.content
            explanation = question.solutions.first.try(:content) || ''
            free_response = 'N/A'
            answer_array = question.answer_choices.to_a
            correct_answer = answer_array.find_index{|a| a.credit > 0}
                                         .try(:+, 97).try(:chr)
            answers = answer_array.collect{|a| a.content}

            s.add_row [tags, list_name, content, explanation,
                       free_response, correct_answer, *answers]
          end
        end

        p.serialize(filename)
        puts "Exported #{questions.count} question(s)."
      end
    end
  end
end
