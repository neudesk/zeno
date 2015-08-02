set :deploy_to, '/var/www/gui-production'
set :branch, 'new_layout'
set :stage, :production
server '107.170.182.22', user: 'deploy', roles: %w{web app db}
