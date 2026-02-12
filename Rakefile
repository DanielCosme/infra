# frozen_string_literal: true

# The $? global variable in Ruby contains the status of the last executed shell command.
# It returns a Process::Status object that provides information about the command's execution.
#  - $?

# NOTE: servers affected are read from inventory.rb file
#
# Rake task: task_name, [:arg1, :arg2] => [:dependency] do |t, args| ; end

desc 'first time setup of ssh, firewall and users'
task :root_init do
  require_relative './tasks/root_init'
  root_init
end

desc 'install tailscale and add server to the tailnet'
task :tailscale do
  require_relative './tasks/tailscale'
  install_tailscale
end

desc 'install caddy'
task :caddy do
  require_relative './tasks/caddy'
  install_caddy
end

desc 'upload Caddyfile to server and refresh'
task :caddy_update_ape0 do
  require_relative './tasks/caddy'
  update_caddyfile
end

desc 'ensures the programs in the list are installed'
task :programs do
  require_relative './tasks/programs'
  ensure_installed
end

desc 'update all servers'
task :update do
  require_relative './tasks/programs'
  update
end

task :install_yay do
  require_relative './tasks/aur'
  install_aur
end

task :encrypt_secrets do
  require_relative './tasks/age'
  encrypt
end

task :decrypt_secrets do
  require_relative './tasks/age'
  decrypt
end

task :install_syncthing do
  require_relative './tasks/syncthing'
  install_syncthing
end

task :gitea_install do
  require_relative './tasks/gitea'
  install_gitea
end

task :gitea_update do
  require_relative './tasks/gitea'
  update_config
end

# Locks ssh, only to be accessed via VPN (tailscale)
task :lock_in_server do
  require_relative './tasks/tailscale'
  lock_in_server
end
