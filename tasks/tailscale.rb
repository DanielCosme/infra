# frozen_string_literal: true

require_relative '../config/inventory'
require_relative '../config/secrets/values'
require_relative '../lib/ssh'

def install_tailscale
  ex = RemoteExecutor.new(SERVER.ip, ADMIN)
  ex.ssh_f('sudo pacman --noconfirm -S tailscale')
  ex.ssh_f('sudo systemctl enable --now tailscaled')
  ex.ssh_f("sudo tailscale up --auth-key=#{TAILSCALE_AUTH_KEY} --hostname=#{SERVER.hostname}")
end

# Locks in the server to connect only via the tailscale device.
def lock_in_server
  ex = RemoteExecutor.new(SERVER.host, ADMIN)
  ex.ssh_seq([
               'sudo ufw status verbose',
               'sudo ufw allow in on tailscale0',
               'sudo ufw delete allow 22/tcp',
               'sudo ufw status verbose',
               'sudo ufw reload',
               'sudo systemctl restart sshd'
             ])
end
