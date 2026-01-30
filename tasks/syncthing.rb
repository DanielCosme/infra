# frozen_string_literal: true

require_relative '../lib/ssh'
require_relative '../lib/server'
require_relative '../config/inventory'

def install_syncthing
  ex = RemoteExecutor.new(SERVERS[:apex].tailscale_domain, ADMIN)
  ex.ssh_seq([
               'sudo useradd -U --create-home syncthing',
               'sudo pacman -S --noconfirm syncthing',
               'sudo systemctl enable --now syncthing@syncthing.service',
               'sudo systemctl status syncthing@syncthing.service'
             ])
  # Create user
end
# http://127.0.0.1:8384

# Need to make synthing web-ui listen in 0.0.0.0
# Before we configure the Web UI username and password, we port-forward.
