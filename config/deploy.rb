require 'bundler/capistrano'
require 'whenever/capistrano'

# This capistrano deployment recipe is made to work with the optional
# StackScript provided to all Rails Rumble teams in their Linode dashboard.
#
# After setting up your Linode with the provided StackScript, configuring
# your Rails app to use your GitHub repository, and copying your deploy
# key from your server's ~/.ssh/github-deploy-key.pub to your GitHub
# repository's Admin / Deploy Keys section, you can configure your Rails
# app to use this deployment recipe by doing the following:
#
# 1. Add `gem 'capistrano'` to your Gemfile.
# 2. Run `bundle install --binstubs --path=vendor/bundles`.
# 3. Run `bin/capify .` in your app's root directory.
# 4. Replace your new config/deploy.rb with this file's contents.
# 5. Configure the two parameters in the Configuration section below.
# 6. Run `git commit -a -m "Configured capistrano deployments."`.
# 7. Run `git push origin master`.
# 8. Run `bin/cap deploy:setup`.
# 9. Run `bin/cap deploy:migrations` or `bin/cap deploy`.
#
# Note: When deploying, you'll be asked to enter your server's root
# password. To configure password-less deployments, see below.

#############################################
## ##
## Configuration ##
## ##
#############################################

GITHUB_REPOSITORY_NAME = 'r12-team-32'
LINODE_SERVER_HOSTNAME = 'welaika-2.r12.railsrumble.com'

#############################################
#############################################

# General Options

set :bundle_flags, "--deployment"

set :application, "railsrumble"
set :deploy_to, "/var/www/apps/railsrumble"
set :normalize_asset_timestamps, false
set :rails_env, "production"

set :user, "root"
set :runner, "www-data"
set :admin_runner, "www-data"

# Password-less Deploys (Optional)
#
# 1. Locate your local public SSH key file. (Usually ~/.ssh/id_rsa.pub)
# 2. Execute the following locally: (You'll need your Linode server's root password.)
#
# cat ~/.ssh/id_rsa.pub | ssh root@LINODE_SERVER_HOSTNAME "cat >> ~/.ssh/authorized_keys"
#
# 3. Uncomment the below ssh_options[:keys] line in this file.
#
ssh_options[:keys] = ["~/.ssh/id_rsa"]

# SCM Options
set :scm, :git
set :repository, "git@github.com:railsrumble/#{GITHUB_REPOSITORY_NAME}.git"
set :branch, "master"

# Roles
role :app, LINODE_SERVER_HOSTNAME
role :db, LINODE_SERVER_HOSTNAME, :primary => true

# Add Configuration Files & Compile Assets
after 'deploy:update_code' do
  # Setup Configuration
  run "cp #{shared_path}/config/database.yml #{release_path}/config/database.yml"

  # Compile Assets
  run "cd #{release_path}; RAILS_ENV=production bundle exec rake assets:precompile"
end

# Restart Passenger
deploy.task :restart, :roles => :app do
  # Fix Permissions
  sudo "chown -R www-data:www-data #{current_path}"
  sudo "chown -R www-data:www-data #{latest_release}"
  sudo "chown -R www-data:www-data #{shared_path}/bundle"
  sudo "chown -R www-data:www-data #{shared_path}/log"

  # Restart Application
  run "touch #{current_path}/tmp/restart.txt"
end

namespace :deploy do
    namespace :assets do
      task :precompile, :roles => :web, :except => { :no_release => true } do
        from = source.next_revision(current_revision)
        if capture("cd #{latest_release} && #{source.local.log(from)} vendor/assets/ app/assets/ | wc -l").to_i > 0
          run %Q{cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:precompile}
        else
          logger.info "Skipping asset pre-compilation because there were no asset changes"
        end
    end
  end
end

namespace :delayed_job do 
    desc "Restart the delayed_job process"
    task :restart, :roles => :app do
        run "cd #{current_path}; RAILS_ENV=#{rails_env} script/delayed_job restart"
    end
    
    desc "Start the delayed_job process"    
    task :start, :roles => :app do
        run "cd #{current_path}; RAILS_ENV=#{rails_env} script/delayed_job start"
    end
    
    desc "Stop the delayed_job process"    
    task :stop, :roles => :app do
        run "cd #{current_path}; RAILS_ENV=#{rails_env} script/delayed_job stop"
    end
end

# Delayed Job  
after "deploy:stop",    "delayed_job:stop"  
after "deploy:start",   "delayed_job:start"  
after "deploy:restart", "delayed_job:restart" 

