# Copyright 2014 Rice University. Licensed under the Affero General Public
# License version 3 or later.  See the COPYRIGHT file for details.

# http://stackoverflow.com/a/2624395
namespace :questions do
  namespace :export do
    task :json, [:filename, :user_id] => :environment do |t, args|
      filename = args[:filename] || 'questions.json'
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

      output = ApplicationController.new.render_to_string(
                 :template => 'questions/search',
                 :locals => {:@questions => questions,
                             :@export => true},
                 :formats => [:jsonify])
      File.open(filename, 'w') { |file| file.write(output) }
      puts "Exported #{questions.count} question(s)."
    end
  end
end
