# Copyright 2014 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

# http://stackoverflow.com/a/2624395
namespace :questions do
  task :export, [:filename] => :environment do |t, args|
    filename = args[:filename] || 'questions.json'
    puts 'Exporting questions. Please wait...'
    output = ApplicationController.new.render_to_string(
               :template => 'questions/search',
               :locals => {:@questions => Question.all,
                           :@export => true},
               :formats => [:jsonify])
    File.open(filename, 'w') { |file| file.write(output) }
  end
end
