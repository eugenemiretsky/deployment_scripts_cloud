# config valid only for current version of Capistrano
lock '3.3.5'

set :application, 'sportsnet_notifications'
set :repo_url, 'git@github.com:digitalmedia/sportsnet_notifications.git'

set :deploy_user, "sportsnet_data"
set :deploy_to, '/clients/sportsnet_notifications'
set :scm, :git
set :format, :pretty

set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'bin')

set :bundle_binstubs, -> { shared_path.join('bin') }

set :rvm_ruby_version, '2.2.0'      # Defaults to: 'default'


before 'bundler:install', "chef123:default"

namespace :deploy do
  task :start_app do
    on roles(:web) do |host|
      execute "sudo monit start notifications"
    end
  end

  task :start_queue do
    on roles(:queue) do |host|
      execute "sudo monit start notifications_sidekiq"
    end
  end

  task :stop do
    on roles(:queue) do |host|
      execute "sudo monit stop notifications_sidekiq"
    end

    on roles(:web) do |host|
      execute "sudo monit stop notifications"
    end
  end

  before :starting, :stop
  after :finished, :start_app
  after :finished, :start_queue
end

namespace :db do
  task :migrate do
    on roles(:db) do
      within release_path do
        with rack_env: fetch(:stage) do
          execute :rake, "db:migrate"
        end
      end
    end
  end

  task :drop do
    on roles(:db) do
      within release_path do
        with rack_env: fetch(:stage) do
          execute :rake, "db:drop"
        end
      end
    end
  end

  task :create do
    on roles(:db) do
      within release_path do
        with rack_env: fetch(:stage) do
          execute :rake, "db:create"
        end
      end
    end
  end

  task :setup do
    on roles(:db) do
      within release_path do
        with rack_env: fetch(:stage) do
          execute :rake, "db:setup"
        end
      end
    end
  end
end
