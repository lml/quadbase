# Copyright (c) 2011 Rice University.  All rights reserved.

namespace :db do
  task :populate_users => :environment do
    create_user("Admin", "de Quadbase")
    create_user("User", "de Quadbase")
    first_names = ["Alice", "Bob", "Carlos", "Carol", "Charlie", "Chuck", "Dave",
                   "Eve", "Fuego", "Mallory", "Peggy", "Trent", "Trudy", "Walter"]
    first_names.each { |fn| create_user(fn) }
  end

  task :populate_license => :environment do
    License.create(
           :short_name => "CC BY 3.0",
           :long_name => "Creative Commons Attribution 3.0 Unported",
           :url => "http://creativecommons.org/licenses/by/3.0/",
           :agreement_partial_name => "cc_by_3_0",
           :is_default => true)
  end

  task :populate => [:populate_users, :populate_license]

  def create_user(first_name = Faker::Name::first_name, last_name = Faker::Name::last_name)
    u = User.new(:first_name => first_name,
                 :last_name => last_name,
                 :email => first_name + "@example.com",
                 :password => "password")
    u.username = first_name.downcase
    u.save!
    u.confirm!
  end
end
