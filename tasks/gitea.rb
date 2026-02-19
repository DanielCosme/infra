# frozen_string_literal: true

require_relative '../lib/ssh'
require_relative '../lib/server'
require_relative '../config/inventory'
require_relative '../config/secrets/values'

def install_gitea
  ex = RemoteExecutor.new(SERVERS[:apex].hostname, ADMIN)
  ex.ssh_seq_f([
                 'git --version',
                 'sudo pacman --noconfirm -S gitea',
                 "sudo -u gitea mkdir -p #{DATAPOOL_PATH}/gitea/custom",
                 'sudo systemctl enable --now gitea'
               ])
  gitea_update_config
end

def gitea_update_config
  ex = RemoteExecutor.new(SERVERS[:apex].hostname, ADMIN)
  ex.scp(from: './config/gitea/app.ini', to: "/home/#{ADMIN}/app.ini")
  ex.ssh_f("sudo mv /home/#{ADMIN}/app.ini /etc/gitea/app.ini")
  ex.ssh_f('sudo chown gitea:gitea /etc/gitea/app.ini')

  ex.scp(from: './config/gitea/gitea.service', to: "/home/#{ADMIN}/gitea.service")
  ex.ssh_seq_f(
    [
      "sudo mv /home/#{ADMIN}/gitea.service /usr/lib/systemd/system/gitea.service",
      'sudo chown root:root /usr/lib/systemd/system/gitea.service',
      'sudo systemctl daemon-reload',
      'sudo systemctl restart gitea && sudo systemctl status gitea'
    ]
  )
end

def gitea_install_runner
  ex = RemoteExecutor.new(SERVERS[:apex].hostname, ADMIN)
  ex.ssh_f('yay --noconfirm -S act-runner-bin')

  ex.scp(from: './config/gitea/act_runner.yaml', to: "/home/#{ADMIN}/act_runner.yaml")
  ex.ssh_f("sudo mv /home/#{ADMIN}/act_runner.yaml /etc/act_runner/act_runner.yaml")
  ex.ssh_f('sudo chown act_runner:act_runner /etc/act_runner/act_runner.yaml')

  # TODO: make sure I can register act_runner automatically. to make this work with sudo -D /var/lib/act_runner via sudoers
  #   arch ALL=(ALL) SETENV: /usr/bin/act_runner
  # ex.ssh_f("sudo  -u act_runner act_runner register --no-interactive --name daniel_runner --instance #{GIT_URL} --token #{GITEA_RUNNER_DANIEL_TOKEN}")
  # ex.ssh_f('sudo systemctl enable --now act_runner && sudo systemctl status act_runner')
end
