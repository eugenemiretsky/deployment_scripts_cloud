server 'stgsnstatsmobile01', user: 'sportsnet_data', roles: %w{web app db cron}
server 'stgsnstatsmobile02', user: 'sportsnet_data', roles: %w{web}, no_release: true
set :rack_env, :staging
