# frozen_string_literal: true

require_relative '../config/inventory'
require_relative '../config/secrets/values'
require_relative '../lib/ssh'

def install_tailscale
  ex = RemoteExecutor.new(SERVER.ip, ADMIN)
  ex.ssh('sudo useradd tailscaled')
  ex.ssh_f('sudo pacman --noconfirm -S tailscale')
  ex.ssh('sudo mkdir -p /etc/polkit-1/localauthority/10-vendor && sudo chmod -R g+w /etc/polkit-1')
  ex.scp(from: './config/tailscale/tailscaled.pkla', to: '/etc/polkit-1/localauthority/10-vendor/tailscale.pkla')
  ex.ssh_f('sudo chmod -R g+w /etc/systemd/system')
  ex.scp(from: './config/tailscale/tailscaled.service', to: '/etc/systemd/system/tailscaled.service')
  ex.ssh_f('sudo systemctl enable --now tailscaled')
  ex.ssh_f("sudo tailscale up --auth-key=#{TAILSCALE_AUTH_KEY} --hostname=#{SERVER.hostname}")
end
