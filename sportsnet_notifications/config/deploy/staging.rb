server 'stgsnstatsmobile01', user: 'sportsnet_data', roles: %w{web app db queue}, primary: true
server 'stgsnstatsmobile02', user: 'sportsnet_data', roles: %w{web app}, no_release: true
set :rack_env, :staging
set :branch, :master
