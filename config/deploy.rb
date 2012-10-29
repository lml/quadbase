# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

DEPLOY_SETTINGS = YAML::load_file(File.join(File.dirname(__FILE__), '/deploy_settings.yml'))

# $:.unshift(File.expand_path('./lib', ENV['rvm_path'])) # Add RVM's lib directory to the load path.
require "rvm/capistrano"                  # Load RVM's capistrano plugin.

set :rvm_ruby_string, 'ruby-1.9.3-p194@quadbase'        # Or whatever env you want it to run in.
set :rvm_type, :system 

set :normalize_asset_timestamps, false # get rid of public/[images, javascripts, ...] warnings

require "bundler/capistrano"

load 'deploy/assets'  # to precompile assets

set :user, DEPLOY_SETTINGS["deploy_server_username"]   # Your server account's username
set :domain, DEPLOY_SETTINGS["domain"]                 # Servername where your account is located 
set :ssh_options, { :forward_agent => true }
set :application, DEPLOY_SETTINGS["application"]
set :applicationdir, DEPLOY_SETTINGS["applicationdir"] # The deploy directory

# version control config

set :repository, "git@github.com:lml/quadbase.git"
set :scm, "git"
set :branch, "master"
set :scm_verbose, true

# roles (servers)

role :web, domain
role :app, domain
role :db,  domain, :primary => true

# deploy config

set :deploy_to, applicationdir
set :deploy_via, :remote_cache

# additional settings

default_run_options[:pty] = true  # Avoid errors when deploying from windows
set :use_sudo, false


# Use this so we don't have to put sensitive data in the git repository (for security)

after "deploy:create_symlink","custom:finishing_touches"
# after "deploy:create_symlink", "rake:bullring"
# after "deploy:assets:symlink", "custom:finishing_touches"

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

namespace :custom do
  task :finishing_touches, :roles => :app do
    run "ln -sFf #{deploy_to}/to_copy/database.yml #{current_path}/config/database.yml"
    run "ln -sFf #{deploy_to}/to_copy/secret_settings.yml #{current_path}/config/secret_settings.yml"
  end
end

# namespace :rake do  
#   desc "Run a task on a remote server."  
#   # run like: cap staging rake:invoke task=a_certain_task  
#   task :bullring do  
#     run("cd #{deploy_to}/current; /usr/bin/env bundle exec rake bullring:discard RAILS_ENV=#{rails_env}")  
#   end  
# end



