# define paths and filenames
deploy_to = "/u/apps/traffic_light_pi_server"
rails_root = "#{deploy_to}/current"
pid_file = "#{deploy_to}/shared/pids/unicorn.pid"
socket_file = "#{deploy_to}/shared/unicorn.sock"
log_file = "#{rails_root}/log/unicorn.log"
err_log = "#{rails_root}/log/unicorn_error.log"

timeout 30
worker_processes 1 # increase or decrease
working_directory rails_root
listen socket_file

pid pid_file
stderr_path err_log
stdout_path log_file

# make sure that Bundler finds the Gemfile
before_exec do |server|
  ENV['BUNDLE_GEMFILE'] = File.expand_path('../Gemfile', File.dirname(__FILE__))
end
