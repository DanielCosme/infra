require 'net/ssh'
require 'net/scp'

host = '137.184.170.253'
raise 'empty host' if host.empty?

key_path = '~/.ssh/id_rsa'
vm_user = 'daniel'
vm_password = ''
raise 'empty vm_password' if vm_password.empty?

Net::SSH.start(host, vm_user, keys: [key_path]) do |ssh|
  commands = [
    "echo #{vm_password} | chsh -s $(which fish)",
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

Net::SCP.start(host, vm_user, keys: [key_path]) do |scp|
  scp.upload!("./config/fish/fish_user_key_bindings.fish", "/home/#{vm_user}/.config/fish/functions/fish_user_key_bindings.fish")
  scp.upload!("./config/fish/config.fish", "/home/#{vm_user}/.config/fish/config.fish")
  puts "Upload complete!"
end
