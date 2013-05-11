require 'bundler/capistrano'

set :application, "traffic_light_pi_server"
set :repository,  "git@github.com:nledez/traffic_light_pi_server_example.git"
set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

# do not use sudo
set :use_sudo, false
set(:run_method) { use_sudo ? :sudo : :run }

# This is needed to correctly handle sudo password prompt
default_run_options[:pty] = true

set :bundle_flags, "--quiet"
set :normalize_asset_timestamps, false

set :user, "root"
set :group, user
set :runner, user

set :host, "#{user}@10.0.0.180"
role :web, host
role :app, host

set :unicorn_conf, "#{deploy_to}/current/config/unicorn.rb"
set :unicorn_pid, "#{deploy_to}/shared/pids/unicorn.pid"

# Unicorn control tasks
#namespace :deploy do
#  task :restart do
#    run "if [ -f #{unicorn_pid} ]; then kill -USR2 `cat #{unicorn_pid}`; else cd #{deploy_to}/current && bundle exec unicorn -c #{unicorn_conf} -E #{rails_env} -D; fi"
#  end
#  task :start do
#    run "cd #{deploy_to}/current && bundle exec unicorn -c #{unicorn_conf} -E #{rails_env} -D"
#  end
#  task :stop do
#    run "if [ -f #{unicorn_pid} ]; then kill -QUIT `cat #{unicorn_pid}`; fi"
#  end
#end

################################################################################
# TASKS
#

namespace :deploy do

  desc "applies the monit config symlink on the web machines"
  task :monit_symlink, :roles => :web do
    run "#{sudo} ln -nfs #{release_path}/config/monit.conf /etc/monit/conf.d/#{application}.conf"
  end

  desc "reloads monit config"
  task :monit_reload do
    run "#{sudo} monit reload"
  end

  desc "applies the nginx config symlink"
  task :nginx_symlink, :roles => :web do
    run "#{sudo} ln -nfs #{release_path}/config/nginx.conf /etc/nginx/sites-enabled/#{application}"
  end

  desc "reloads nginx config"
  task :nginx_reload, :roles => :web do
    run "#{sudo} /etc/init.d/nginx reload"
  end

  desc "start the app"
  task :start, :roles => :web do
    run "#{sudo} monit start #{application}"
  end

  desc "stop the app"
  task :stop, :roles => :web do
    run "#{sudo} monit stop #{application}"
  end

  desc "restart the app"
  task :restart, :roles => :web do
    if update_db?
      run "#{sudo} monit stop #{application}"
      run "cd #{current_release} && bundle exec rake db:migrate"
      run "cd #{current_release} && bundle exec rake db:seed"
      run "#{sudo} monit start #{application}"
    else
      run "#{sudo} monit restart #{application}"
    end
  end

end

################################################################################
# CALLBACKS
#

after "deploy:finalize_update",
  "deploy:monit_symlink",
  "deploy:nginx_symlink"

before "deploy:restart",
  "deploy:monit_reload",
  "deploy:nginx_reload"

after "deploy:restart",
  "deploy:cleanup" # keep the last 5 releases
