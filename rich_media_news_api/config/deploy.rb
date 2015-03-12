# config valid only for current version of Capistrano
lock '3.3.5'

set :application, 'rich_media_news_api'
set :repo_url, 'git@github.com:digitalmedia/rich_media_news_api.git'
set :branch, 'live'
set :deploy_to, '/clients/rich_media_news_api'
set :keep_releases, 3
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'pid')
set :rvm_ruby_string, 'ruby-2.2.0'
set :rvm_ruby_version, '2.2.0' 
set :rvm_type, :system
set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }
set :whenever_roles, -> { :cron }

namespace :deploy do

  task :start do
    on roles(:web) do |host|
      within release_path do
        with rack_env: fetch(:stage) do 
          execute "rm -fr #{shared_path}/logs"
          execute "sudo monit start rmnf || true"
        end
      end
    end
  end

  task :stop do
    on roles(:web) do |host|
      within release_path do
        execute "rm -fr #{shared_path}/tmp/pids"
        execute "sudo monit stop rmnf || true"
      end
    end
  end

  desc 'Apply migrations'
  task :migrate do
    on roles(:app) do
      within release_path do
        with rack_env: fetch(:stage) do 
          execute :rake, "db:migrate"
        end
      end
    end
  end

  desc 'Create DB'
  task :create_db do
    on roles(:db) do
      within release_path do
        with rack_env: fetch(:stage) do
          execute :bundle, :exec, :rake, "db:drop db:create db:migrate reindex"
        end
      end
    end
  end

  desc 'Create DB'
  task :init do
    on roles(:db) do
      within release_path do
        with rack_env: fetch(:stage) do
          execute :bundle, :exec, :rake, "rss:fetch xml:fetch audio:fetch livetv:fetch reindex"
        end
      end
    end
  end

  desc 'Reindex solr'
  task :reindex do
    on roles(:db) do
      within release_path do
        with rack_env: fetch(:stage) do
          execute :bundle, :exec, :rake, "reindex"
        end
      end
    end
  end

  task :stop_cron do
  end

  task :start_cron do
  end

  after :published, :stop
  after :published, :migrate
  after :published, :reindex
  after :published, :start
  after :start_cron, "whenever:update_crontab"
  after :stop_cron, "whenever:clear_crontab"

end
