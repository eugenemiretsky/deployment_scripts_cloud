server 'snstatsmobile03', user: 'sportsnet_data', roles: %w{web app db cron}
server 'snstatsmobile04', user: 'sportsnet_data', roles: %w{web}, no_release: true
set :rack_env, :production
