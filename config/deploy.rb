require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/multistage'
require 'mina/tail'
require 'mina/puma'
# require 'mina/rbenv'  # for rbenv support. (http://rbenv.org)
require 'mina/rvm'    # for rvm support. (http://rvm.io)

# Basic settings:
#   domain       - The hostname to SSH to.
#   deploy_to    - Path to deploy into.
#   repository   - Git repo to clone from. (needed by mina/git)
#   branch       - Branch name to deploy. (needed by mina/git)

set :application_name, 'support_bot'
set :repository, 'alfiemax@bitbucket.org:alfiemax/slack-server-bot.git'

# For system-wide RVM install.
#   set :rvm_path, '/usr/local/rvm/bin/rvm'

# Manually create these paths in shared/ (eg: shared/config/database.yml) in your server.
# They will be linked in the 'deploy:link_shared_paths' step.
set :shared_paths, [
  'log', 'pids', 'tmp/pids', 'tmp/sockets', 'public/uploads',
  'config/database.yml', 'config/secrets.yml', 'config/application.yml'
]

# Optional settings:
set :user, 'root'          # Username in the server to SSH to.
set :forward_agent, true     # SSH forward_agent.
set :term_mode, nil
#   set :port, '30000'     # SSH port number.
set :rvm_path, '/usr/local/rvm/scripts/rvm'

# This task is the environment that is loaded for most commands, such as
# `mina deploy` or `mina rake`.
task :environment do
  # If you're using rbenv, use this to load the rbenv environment.
  # Be sure to commit your .ruby-version or .rbenv-version to your repository.
  # invoke :'rbenv:load'

  # For those using RVM, use this to load an RVM version@gemset.
  invoke :'rvm:use[ruby-2.4.1]'
end

# Put any custom mkdir's in here for when `mina setup` is ran.
# For Rails apps, we'll make some of the shared paths that are shared between
# all releases.
task setup: :environment do
  queue! %(mkdir -p "#{deploy_to}/#{shared_path}/tmp/sockets")
  queue! %(chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/tmp/sockets")
  queue! %(mkdir -p "#{deploy_to}/#{shared_path}/tmp/pids")
  queue! %(chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/tmp/pids")

  queue! %(mkdir -p "#{deploy_to}/#{shared_path}/pids")
  queue! %(chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/pids")

  queue! %(mkdir -p "#{deploy_to}/#{shared_path}/log")
  queue! %(chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/log")

  queue! %(mkdir -p "#{deploy_to}/#{shared_path}/config")
  queue! %(chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/config")

  queue! %(mkdir -p "#{deploy_to}/#{shared_path}/public/uploads")
  queue! %(chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/public/uploads")

  queue! %(touch "#{deploy_to}/#{shared_path}/config/database.yml")
  queue! %(touch "#{deploy_to}/#{shared_path}/config/secrets.yml")
  queue! %(touch "#{deploy_to}/#{shared_path}/config/application.yml")
  queue  %(echo "-----> Be sure to edit '#{deploy_to}/#{shared_path}/config/database.yml', application.yml and 'secrets.yml'.")

  if repository
    repo_host = repository.split(%r{@|://}).last.split(%r{:|\/}).first
    repo_port = /:([0-9]+)/.match(repository) && /:([0-9]+)/.match(repository)[1] || '22'

    queue %(
      if ! ssh-keygen -H  -F #{repo_host} &>/dev/null; then
        ssh-keyscan -t rsa -p #{repo_port} -H #{repo_host} >> ~/.ssh/known_hosts
      fi
    )
  end
end

desc 'Deploys the current version to the server.'
task deploy: :environment do
  to :before_hook do
    # Put things to run locally before ssh
  end
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_create'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'
    invoke :'deploy:cleanup'

    to :launch do
      invoke :'puma:stop'
      invoke :'puma:start'
    end
  end
end

desc 'Restart nginx server'
task :restart do
  queue 'sudo service nginx restart'
end

desc 'Seed data to the database'
task seed: :environment do
  queue "cd #{deploy_to}/current"
  queue "bundle exec rake db:seed RAILS_ENV=#{rails_env}"
end

namespace :provision do
  desc "Install redis server"
  task :redis do
    queue "sudo add-apt-repository -y ppa:chris-lea/redis-server"
    queue "sudo apt-get update -y"
    queue "sudo apt-get install -y redis-server"
    queue "sudo apt-get clean -y"
  end
end

# For help in making your deploy script, see the Mina documentation:
#
#  - http://nadarei.co/mina
#  - http://nadarei.co/mina/tasks
#  - http://nadarei.co/mina/settings
#  - http://nadarei.co/mina/helpers