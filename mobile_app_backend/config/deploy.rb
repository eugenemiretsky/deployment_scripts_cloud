# config valid only for current version of Capistrano
lock '3.3.5'

set :application, 'mobile_app_backend'
set :repo_url, 'git@github.com:digitalmedia/mobile_app_backend.git'
set :branch, 'live'
set :deploy_to, '/clients/mobile_app_backend'
set :keep_releases, 3
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'pid')
set :rvm_ruby_string, 'ruby-2.2.0'
set :rvm_ruby_version, '2.2.0' 
set :rvm_type, :system
set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }
set :whenever_roles, -> { :web }

set :rollbar_token, '21a681ad5cdb40e191a55cadd7fc5534'
set :rollbar_env, Proc.new { fetch :stage }
set :rollbar_role, Proc.new { :app }

namespace :deploy do

  task :start_stats do
    on roles(:web) do |host|
      execute "sudo monit start stats"
    end
  end

  task :start_queue do
    on roles(:queue) do |host|
      execute "sudo monit start stats_sidekiq"
    end
  end

  task :start_processor do
    on roles(:proc) do |host|
      execute "sudo monit start processor"
    end
  end

  task :stop do
    on roles(:web) do |host|
      execute "sudo monit stop stats"
    end
    on roles(:proc) do |host|
      execute "sudo monit stop processor"
    end
    on roles(:queue) do |host|
      execute "sudo monit stop stats_sidekiq"
    end
  end

  desc 'Apply migrations'
  task :migrate do
    on roles(:db) do
      within release_path do
        with rack_env: fetch(:stage) do
          execute :bundle, :exec, :rake, "db:migrate"
        end
      end
    end
  end

  after :published, :stop
  after :published, :migrate
  after :published, :start_stats
  after :published, :start_processor
  after :published, :start_queue
  after :published, "whenever:update_crontab"

  desc 'Create DB'
  task :create_db do
    on roles(:db) do
      within release_path do
        with rack_env: fetch(:stage) do
          execute :bundle, :exec, :rake, "db:drop db:create db:migrate db:seed"
          #execute :bundle, :exec, :rake, "db:migrate db:seed"
        end
      end
    end
  end

  desc 'Run history saver'
  task :save_history do
    on roles(:db) do
      within release_path do
        with rack_env: fetch(:stage) do
          execute :bundle, :exec, :rake, "history:save"
        end
      end
    end
  end

  desc 'Load bootstrap data'
  task :bootstrap do
    on roles(:db) do
      within release_path do
        with rack_env: fetch(:stage) do 
          execute :bundle, :exec, :rake, "db:seed"
        end
      end
    end
  end

  desc 'Load broadcast data'
  task :broadcast do
    on roles(:db) do
      within release_path do
        with rack_env: fetch(:stage) do 
          execute :bundle, :exec, :rake, "fetch_broadcast"
        end
      end
    end
  end
end
