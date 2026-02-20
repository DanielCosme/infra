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
  ex = RemoteExecutor.new(SERVER.hostname, ADMIN)
  ex.scp(from: './config/caddy/Caddyfile', to: "/home/#{ADMIN}/Caddyfile")
  ex.ssh_f('sudo mv ~/Caddyfile /etc/caddy/Caddyfile && sudo systemctl restart caddy && sudo systemctl status caddy')
end
