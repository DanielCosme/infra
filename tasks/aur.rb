# frozen_string_literal: true

require_relative '../config/inventory'
require_relative '../lib/ssh'

def install_aur
  SERVER_LIST.each do |s|
    ex = RemoteExecutor.new(s.hostname, ADMIN)
    ex.ssh('rm -r ./yay')
    ex.ssh_f('git clone https://aur.archlinux.org/yay.git')
    ex.ssh_f('cd yay && makepkg -si --noconfirm && yay --version')
  end
end
