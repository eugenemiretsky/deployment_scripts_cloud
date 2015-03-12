server 'snstatsmobile01', user: 'sportsnet_data', roles: %w{web app db proc}
server 'snstatsmobile02', user: 'sportsnet_data', roles: %w{web queue}, no_release: true
set :rack_env, :production
