# frozen_string_literal: true

require_relative '../lib/ssh'
require_relative '../lib/server'
require_relative '../config/inventory'
require_relative '../config/secrets/values'

def loki_install
  ex = RemoteExecutor.new(SERVERS[:apex].hostname, ADMIN)
  ex.ssh_f('sudo pacman --noconfirm -S loki', print: false)
  ex.ssh_f('sudo systemctl enable --now loki')
  loki_update_config
  grafana_install
  grafana_alloy_install
end

def loki_update_config
  ex = RemoteExecutor.new(SERVERS[:apex].hostname, ADMIN)
  ex.scp(from: './config/loki/loki.yaml', to: "/home/#{ADMIN}/loki.yaml")
  ex.ssh_seq_f([
                 "sudo mv /home/#{ADMIN}/loki.yaml /etc/loki/loki.yaml",
                 'sudo chown loki:loki /etc/loki/loki.yaml',
                 'sudo systemctl restart loki && sudo systemctl status loki'
               ])
end

def grafana_install
  ex = RemoteExecutor.new(SERVERS[:apex].hostname, ADMIN)
  ex.ssh_seq_f([
                 'sudo pacman --noconfirm -S grafana',
                 'sudo systemctl enable --now grafana',
                 'sudo systemctl status grafana'
               ])
end

def grafana_alloy_install
  ex = RemoteExecutor.new(SERVERS[:ape0].hostname, ADMIN)
  ex.ssh_seq_f([
                 'sudo pacman --noconfirm -S grafana-alloy',
                 'sudo systemctl enable --now grafana-alloy',
                 'sudo usermod -aG adm grafana-alloy && sudo usermod -aG systemd-journal grafana-alloy && groups grafana-alloy'
               ])
  grafana_alloy_update_config
end

def grafana_alloy_update_config
  ex = RemoteExecutor.new(SERVERS[:ape0].hostname, ADMIN)
  ex.scp(from: './config/loki/grafana-alloy', to: "/home/#{ADMIN}/grafana-alloy")
  ex.ssh_seq_f([
                 "sudo mv /home/#{ADMIN}/grafana-alloy /etc/default/grafana-alloy",
                 'sudo chown grafana-alloy:grafana-alloy /etc/default/grafana-alloy'
               ])

  ex.scp(from: './config/loki/config.alloy', to: "/home/#{ADMIN}/config.alloy")
  ex.ssh_seq_f([
                 "sudo mv /home/#{ADMIN}/config.alloy /etc/grafana-alloy/config.alloy",
                 'sudo chown grafana-alloy:grafana-alloy /etc/grafana-alloy/config.alloy',
                 'sudo systemctl restart grafana-alloy && sudo systemctl status grafana-alloy'
               ])
end
