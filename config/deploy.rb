require 'bundler/capistrano'

default_run_options[:pty] = true
ssh_options[:forward_agent] = true
ssh_options[:keys] = %w(~/.ssh/id_rsa.pub)

set :application, "event-daemon"
set :domain,      "usg.case.edu"
set :repository,  "git://github.com/cwru-usg/event-daemon.git"
set :use_sudo,    false
set :user,        "usgit-deploy"
set :deploy_to,   "/var/deploy/#{application}"
set :scm,         "git"

role :app, domain
role :web, domain
role :db,  domain, :primary => true

namespace :deploy do
  task :start, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end

  task :stop, :roles => :app do
    # Do nothing.
  end

  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end

  desc "Symlink important configuration files"
  task :config_symlink, :roles => :app do
    run "ln -fs #{shared_path}/config/database.yml #{release_path}/config/"
    run "ln -fs #{shared_path}/config/initializers/collegiatelink.rb #{release_path}/config/initializers/"
    run "ln -fs #{shared_path}/config/initializers/mail.rb #{release_path}/config/initializers/"
  end

  namespace :assets do
    task :precompile, :roles => :app do
      run "cd #{current_release} && rake assets:precompile"
    end
  end
end

after 'deploy', 'deploy:assets:precompile'
after 'deploy:create_symlink', 'deploy:config_symlink'
after 'deploy:config_symlink', 'deploy:migrate'
