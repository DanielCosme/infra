# frozen_string_literal: true

require_relative '../lib/ssh'
require_relative '../lib/server'
require_relative '../config/inventory'
require_relative '../config/secrets/values'

VERSION = '1.29.3'
VERSION_UI = '2.45.3'

def temporal_install
  path = "./tmp/temporal_#{VERSION}.tar.gz"
  path_ui = "./tmp/temporal-ui_#{VERSION_UI}.tar.gz"
  unless File.exist?(path)
    puts 'Downloading Temporal binaries'
    `curl -L -o #{path}  https://github.com/temporalio/temporal/releases/download/v#{VERSION}/temporal_#{VERSION}_linux_amd64.tar.gz`
  end
  unless File.exist?(path_ui)
    puts 'Downloading Temporal UI binaries'
    `curl -L -o #{path_ui}  https://github.com/temporalio/ui-server/releases/download/v#{VERSION_UI}/ui-server_#{VERSION_UI}_linux_amd64.tar.gz`
  end

  `tar -xzf #{path} -C ./tmp`
  `tar -xf #{path_ui} -C ./tmp`

  ex = RemoteExecutor.new(SERVERS[:apex].hostname, ADMIN)
  ex.scp(from: './tmp/temporal-server', to: "/home/#{ADMIN}/temporal-server")
  ex.ssh_f("sudo mv /home/#{ADMIN}/temporal-server /usr/local/sbin/temporal-server")
  ex.ssh_f('sudo chown root:root /usr/local/sbin/temporal-server')

  ex.scp(from: './tmp/ui-server', to: "/home/#{ADMIN}/temporal-ui")
  ex.ssh_f("sudo mv /home/#{ADMIN}/temporal-ui /usr/local/sbin/temporal-ui")
  ex.ssh_f('sudo chown root:root /usr/local/sbin/temporal-ui')

  ex.ssh_seq([
               'sudo useradd temporal',
               'sudo mkdir -p /etc/temporal',
               'sudo chown temporal /etc/temporal'
             ])
  update_configuration
  ex.ssh_f('sudo systemctl enable --now temporal')
  ex.ssh_f('sudo systemctl enable --now temporal-ui')
end

def update_configuration
  ex = RemoteExecutor.new(SERVERS[:apex].hostname, ADMIN)
  ex.scp(from: './config/temporal/temporal-server.yaml', to: "/home/#{ADMIN}/temporal-server.yaml")
  ex.ssh_f("sudo mv /home/#{ADMIN}/temporal-server.yaml /etc/temporal/temporal-server.yaml")
  ex.ssh_f('sudo chown temporal:temporal /etc/temporal/temporal-server.yaml')

  ex.scp(from: './config/temporal/temporal.service', to: "/home/#{ADMIN}/temporal.service")
  ex.ssh_f("sudo mv /home/#{ADMIN}/temporal.service /etc/systemd/system/temporal.service")
  ex.ssh_f('sudo chown root:root /etc/systemd/system/temporal.service')
  ex.ssh_f('sudo systemctl daemon-reload')
  ex.ssh_f('sudo systemctl restart temporal && sudo systemctl status temporal')

  ex.scp(from: './config/temporal/temporal-ui-server.yaml', to: "/home/#{ADMIN}/temporal-ui-server.yaml")
  ex.ssh_f("sudo mv /home/#{ADMIN}/temporal-ui-server.yaml /etc/temporal/temporal-ui-server.yaml")
  ex.ssh_f('sudo chown temporal:temporal /etc/temporal/temporal-ui-server.yaml')

  ex.scp(from: './config/temporal/temporal-ui.service', to: "/home/#{ADMIN}/temporal-ui.service")
  ex.ssh_f("sudo mv /home/#{ADMIN}/temporal-ui.service /etc/systemd/system/temporal-ui.service")
  ex.ssh_f('sudo chown root:root /etc/systemd/system/temporal-ui.service')
  ex.ssh_f('sudo systemctl daemon-reload')
  ex.ssh_f('sudo systemctl restart temporal-ui && sudo systemctl status temporal-ui')
end
