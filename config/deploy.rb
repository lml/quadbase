# Copyright (c) 2011 Rice University.  All rights reserved.

DEPLOY_SETTINGS = YAML::load_file(File.join(File.dirname(__FILE__), '/deploy_settings.yml'))

require "bundler/capistrano"

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
after 'deploy:finishing_touches'

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
  task :finishing_touches, :roles => :app do
    run "ln -s #{deploy_to}/to_copy/database.yml #{current_path}/config/database.yml"
    run "ln -s #{deploy_to}/to_copy/secret_settings.yml #{current_path}/config/secret_settings.yml"
  end
end

