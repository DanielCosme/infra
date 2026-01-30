# frozen_string_literal: true

require_relative '../lib/ssh'
require_relative '../lib/server'
require_relative '../config/inventory'

def root_init(password = '..')
  puts "ip: #{SERVER.ip}"
  puts "server: #{SERVER.hostname}"

  # NOTE: runs as root.
  #   - Setup users: user(sudoer) and admin(sudoer with no password)
  #   - Allow ssh access to those users.
  #   - Disable password login and root login over ssh.
  #   - Block all ports and listen only on port 22 for sshd.
  ex = RemoteExecutor.new(SERVER.ip, :root)
  programs = {
    sudo: 'execute commands as another user',
    vi: 'editor for visudo',
    git: 'version control',
    vim: 'editor',
    ufw: 'firewall',
    btop: 'resource monitor',
    curl: 'transfer URLs',
    "man-db": 'man pages',
    fish: 'modern shell',
    fastfetch: 'I use arch BTW'
  }

  res = ex.ssh('hostnamectl | grep "Operating System: Arch Linux"')
  abort 'not an Arch Linux installation' if res.exitstatus.nonzero?

  ex.ssh_f('echo "Installing packages..."')
  ex.ssh_f("pacman --noconfirm -S #{programs.keys.join(' ')}", print: false)
  ex.ssh_f("timedatectl set-timezone #{TIMEZONE} && timedatectl")

  ex_home = ex.ssh_f("echo \$HOME", print: false).strip
  ex.scp(from: './config/secrets/authorized_keys', to: "#{ex_home.strip}/.ssh/authorized_keys")
  ex.ssh_seq([
               'rm /etc/sudoers.d/90-cloud-init-users', # we dont use the users from cloud-init.
               'userdel -r arch', # digital ocean has by default the arch user.
               "useradd -m #{ADMIN}",
               "mkdir /home/#{ADMIN}/.ssh && chown -R #{ADMIN} /home/#{ADMIN}",
               "cp ~/.ssh/authorized_keys /home/#{ADMIN}/.ssh/authorized_keys && chown -R #{ADMIN} /home/#{ADMIN}/.ssh",
               "usermod -G root #{ADMIN}",
               "touch /etc/sudoers.d/admin && echo '#{ADMIN} ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/admin",
               "touch /etc/sudoers.d/wheel && echo '%wheel ALL=(ALL:ALL) ALL' > /etc/sudoers.d/wheel"
             ])
  ex.ssh_seq([
               "useradd -m --shell /usr/bin/fish -G wheel -U #{USER}",
               "echo #{USER}:#{password} | chpasswd",
               "mkdir /home/#{USER}/.ssh",
               "cp ~/.ssh/authorized_keys /home/#{USER}/.ssh/authorized_keys && chown -R #{USER}:#{USER} /home/#{USER}/.ssh"
             ])

  ex.scp(from: './config/fish/fish_user_key_bindings.fish',
         to: "/home/#{USER}/.config/fish/functions/fish_user_key_bindings.fish")
  ex.scp(from: './config/fish/config.fish',
         to: "/home/#{USER}/.config/fish/config.fish")
  ex.ssh_f("chown -R #{USER}:#{USER} /home/#{USER}/.config/fish")
  ex.scp(from: './config/sshd/sshd_config',
         to: '/etc/ssh/sshd_config')
  # NOTE: I may need to disable iptables for ufw to work properly.
  ex.ssh_f('ufw allow 22/tcp && ufw --force enable && systemctl enable --now ufw && ufw status')
  ex.ssh_f('systemctl reload sshd && fastfetch && echo "Setup successful! Will reboot now!" && systemctl soft-reboot')
end
