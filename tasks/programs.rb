# frozen_string_literal: true

require_relative '../config/inventory'
require_relative '../lib/ssh'
require_relative '../lib/server'

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
    if s.os == OS::ARCH_LINUX
      ex = RemoteExecutor.new(s.tailscale_domain, ADMIN)
      puts "Updating: #{s.tailscale_domain}"
      ex.ssh_f('sudo pacman --noconfirm -Syu')
      puts ''
    else
      puts "#{s.os}: not configured"
    end
  end
end

def iscsi
  # This is needed for Longhorn (in Kubernetes) to work.
  HYDRA_CLUSTER.each do |s|
    ex = RemoteExecutor.new(s.hostname, ADMIN)
    ex.ssh_seq_f([
                   'sudo pacman --noconfirm -S open-iscsi',
                   'sudo systemctl enable --now iscsid.service'
                 ])
  end
end
