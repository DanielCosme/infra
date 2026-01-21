require 'net/ssh'
require 'net/scp'

host = '137.184.170.253'
raise 'empty host' if host.empty?

key_path = '~/.ssh/id_rsa'
timezone = 'America/Toronto'
vm_admin = 'wheel'
vm_user = 'daniel'
vm_password = ''
raise 'empty vm_password' if vm_password.empty?

Net::SSH.start(host, :root, keys: [key_path]) do |ssh|
  commands = [
    # "",
    "apt install -y git fish vim curl wget ufw rsync btop debian-keyring debian-archive-keyring apt-transport-https",
    "timedatectl set-timezone #{timezone} && timedatectl",
    "useradd -U --create-home --groups sudo #{vm_admin}",
    "mkdir /home/#{vm_admin}/.ssh",
    "cp ~/.ssh/authorized_keys /home/#{vm_admin}/.ssh/authorized_keys && chown -R #{vm_admin}:#{vm_admin} /home/#{vm_admin}/.ssh",
    "touch /etc/sudoers.d/admin && echo '#{vm_admin} ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/admin",
    "useradd -U --create-home --shell /usr/bin/fish --groups sudo #{vm_user}",
    "echo #{vm_user}:#{vm_password} | chpasswd",
    "mkdir /home/#{vm_user}/.ssh",
    "cp ~/.ssh/authorized_keys /home/#{vm_user}/.ssh/authorized_keys && chown -R #{vm_user}:#{vm_user} /home/#{vm_user}/.ssh",
    "sudo apt install fail2ban python3-systemd -y",
    "sudo systemctl enable --now fail2ban && sudo systemctl status fail2ban",
  ]

  stdout_data = ""
  stderr_data = ""
  exit_status = nil
  commands.each do |cmd|
    ssh.exec!(cmd) do |channel, stream, data|
      if stream == :stdout
        stdout_data += data
        print data   # stream live if you want
      elsif stream == :stderr
        stderr_data += data
        warn data
      end

      channel.on_close { exit_status = channel[:exit_status] }
    end
  end
end

Net::SCP.start(host, :root, keys: [key_path]) do |scp|
  scp.upload!("./config/sshd/sshd_config", "/etc/ssh/sshd_config")
  puts "Upload complete!"
end

Net::SSH.start(host, :root, keys: [key_path]) do |ssh|
  commands = [
    "ufw allow OpenSSH && ufw --force enable",
    "systemctl reload ssh && systemctl reboot",
  ]

  stdout_data = ""
  stderr_data = ""
  exit_status = nil
  commands.each do |cmd|
    ssh.exec!(cmd) do |channel, stream, data|
      if stream == :stdout
        stdout_data += data
        print data   # stream live if you want
      elsif stream == :stderr
        stderr_data += data
        warn data
      end

      channel.on_close { exit_status = channel[:exit_status] }
    end
  end
end

# class RemoteExecutor
#   def initialize(host, user, opts = {})
#     @host = host
#     @user = user
#     @opts = opts
#   end
# 
#   def run(cmd)
#     Net::SSH.start(@host, @user, @opts) do |ssh|
#       result = ssh.exec!(cmd)
#       raise "Command failed: #{result.exit_status}" if result.exit_status != 0
#       result
#     end
#   end
# end
# 
# executor = RemoteExecutor.new('vps.example.com', 'deploy', keys: ['~/.ssh/id_ed25519'])
# executor.run("uptime")
