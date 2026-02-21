# frozen_string_literal: true

require_relative '../config/inventory'
require_relative '../lib/ssh'

def install_caddy
  ex = RemoteExecutor.new(SERVER.ip, ADMIN)
  ex.ssh_f('sudo pacman --noconfirm -S caddy', print: false)
  ex.ssh('sudo systemctl enable --now caddy && sudo systemctl status caddy')
  ex.scp(from: './config/caddy/Caddyfile', to: "/home/#{ADMIN}/Caddyfile")
  ex.ssh_f('sudo mv ~/Caddyfile /etc/caddy/Caddyfile && sudo systemctl restart caddy')
  ex.ssh_f('sudo ufw allow proto tcp from any to any port 80,443')
  ex.ssh_f('sudo ufw reload && sudo ufw status')
end

def update_caddyfile
  caddy_validate
  ex = RemoteExecutor.new(SERVER.hostname, ADMIN)
  ex.scp(from: './config/caddy/Caddyfile', to: "/home/#{ADMIN}/Caddyfile")
  ex.ssh_f('sudo mv ~/Caddyfile /etc/caddy/Caddyfile && sudo systemctl restart caddy && sudo systemctl status caddy')
end

def caddy_validate
  system('caddy fmt --overwrite --config ./config/caddy/Caddyfile')
  raise "caddy fmt failed with exit code #{$?.exitstatus}" unless $?.success?

  system('caddy validate --config ./config/caddy/Caddyfile')
  raise "caddy validate failed with exit code #{$?.exitstatus}" unless $?.success?
end
