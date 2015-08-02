set :application, 'front-end-development'
set :repo_url, 'git@git.assembla.com:front-end-development.git'
set :deploy_via, :remote_cache
set :linked_files, %w{config/database.yml}
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

set :stage, lambda{ config_name.split(':').last }

namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :finishing, 'deploy:cleanup'
  after :finishing, 'deploy:restart'
end