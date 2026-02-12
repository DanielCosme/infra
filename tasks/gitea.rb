# frozen_string_literal: true

require_relative '../lib/ssh'
require_relative '../lib/server'
require_relative '../config/inventory'

def install_gitea
  ex = RemoteExecutor.new(SERVERS[:apex].hostname, ADMIN)
  ex.ssh_seq_f([
                 'git --version',
                 'sudo pacman --noconfirm -S gitea',
                 "sudo -u gitea mkdir -p #{DATAPOOL_PATH}/gitea/custom",
                 'sudo systemctl enable --now gitea'
               ])
  update_config
end

def update_config
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
