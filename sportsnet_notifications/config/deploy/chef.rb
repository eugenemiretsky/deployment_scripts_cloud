Capistrano::Configuration.instance(:must_exist).load do
  namespace :chef do
    task :default do
      run "chef-client" 
    end
  end
end
