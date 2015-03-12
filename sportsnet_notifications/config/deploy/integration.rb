server 'intsnstatsmobile01', user: 'sportsnet_data', roles: %w{web app db queue}, primary: true
set :rack_env, :integration
set :branch, :develop
