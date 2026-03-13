require_relative '../config/inventory'
require_relative '../lib/ssh'

def k3s_install
  ex = RemoteExecutor.new(SERVERS[:charlie].hostname, FEDORA_ADMIN)

  puts 'Checking Fedora Installation'
  res = ex.ssh('hostnamectl | grep "Operating System: Fedora Linux"')
  abort 'not a Fedora Linux installation' if res.exitstatus.nonzero?

  puts 'Installing extra kernel modules and configuring fiewall values'
  ex.ssh_seq([
               'sudo dnf install -y kernel-modules-extra',
               'sudo firewall-cmd --permanent --add-port=6443/tcp #apiserver',
               'sudo firewall-cmd --permanent --zone=trusted --add-source=10.42.0.0/16', # pods
               'sudo firewall-cmd --permanent --zone=trusted --add-source=10.43.0.0/16', # services
               'sudo firewall-cmd --reload'
             ])
  ex.ssh('sudo -u root mkdir -p /etc/rancher/k3s')
  ex.scp_root(from: './config/k3s/config.yaml', to: '/etc/rancher/k3s/config.yaml')
  ex.ssh_f('curl -sfL https://get.k3s.io | sh -')
end
