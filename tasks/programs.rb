# frozen_string_literal: true

require_relative '../config/inventory'
require_relative '../lib/ssh'

def ensure_installed
  programs = {
    "arch-install-scripts": 'Scripts to aid in installing Arch Linux (I want genfstab)',
    "base-devel": 'basic tools needed to build Arch Linux packages',
    wget: 'non-interactive network downloader',
    rsync: 'fast, versatile, remote (and local) file-copying tool'
  }

  SERVER_LIST.each do |s|
    ex = RemoteExecutor.new(s.hostname, ADMIN)
    ex.ssh_f("sudo pacman --noconfirm -S #{programs.keys.join(' ')}")
  end
end

def update
  SERVER_LIST.each do |s|
    ex = RemoteExecutor.new(s.tailscale_domain, ADMIN)
    puts "Updating: #{s.tailscale_domain}"
    ex.ssh_f('sudo pacman --noconfirm -Syu')
    puts ''
  end
end
