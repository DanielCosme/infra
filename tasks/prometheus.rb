# frozen_string_literal: true

require_relative '../lib/ssh'
require_relative '../lib/server'
require_relative '../config/inventory'
require_relative '../config/secrets/values'

def prometheus_install
  ex = RemoteExecutor.new(SERVERS[:apex].hostname, ADMIN)
  ex.ssh_f('sudo pacman --noconfirm -S prometheus')
  ex.ssh_f('sudo systemctl enable --now prometheus')
  prometheus_update_config
  prometheus_install_node_exporter
end

def prometheus_install_node_exporter
  ex = RemoteExecutor.new(SERVERS[:ape0].hostname, ADMIN)
  ex.ssh_f('sudo pacman --noconfirm -S prometheus-node-exporter')
  ex.ssh_f('sudo systemctl enable --now prometheus-node-exporter')
end

def prometheus_update_config
  ex = RemoteExecutor.new(SERVERS[:apex].hostname, ADMIN)
  ex.scp(from: './config/prometheus/prometheus', to: "/home/#{ADMIN}/prometheus")
  ex.ssh_seq_f([
                 "sudo mv /home/#{ADMIN}/prometheus /etc/conf.d/prometheus",
                 'sudo chown root:root /etc/conf.d/prometheus'
               ])

  ex.scp(from: './config/prometheus/prometheus.yml', to: "/home/#{ADMIN}/prometheus.yml")
  ex.ssh_seq_f([
                 "sudo mv /home/#{ADMIN}/prometheus.yml /etc/prometheus/prometheus.yml",
                 'sudo chown prometheus:prometheus /etc/prometheus/prometheus.yml',
                 'sudo systemctl restart prometheus && sudo systemctl status prometheus'
               ])
end
