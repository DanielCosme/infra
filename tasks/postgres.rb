# frozen_string_literal: true

require_relative '../lib/ssh'
require_relative '../lib/server'
require_relative '../lib/postgres'
require_relative '../config/inventory'
require_relative '../config/secrets/values'

PG = 'postgres'
ROOT_PATH = "/var/lib/#{PG}"

def pg_setup
  # NOTE: NOT IDEMPOTENT
  ex = RemoteExecutor.new(SERVERS[:apex].hostname, ADMIN)
  ex.ssh("sudo btrfs subvolume create #{DATAPOOL_PATH}/#{PG}")
  ex.ssh("sudo useradd -U #{PG}")
  ex.ssh("sudo mkdir -p #{ROOT_PATH}")
  ex.ssh("sudo mount -o subvol=#{PG} /dev/sdc #{ROOT_PATH}")
  ex.ssh("sudo chown -R #{PG}:#{PG} #{ROOT_PATH}")
  ex.ssh("sudo chattr +C #{ROOT_PATH}")
  ex.ssh("sudo lsattr #{DATAPOOL_PATH}")
  puts "Don't forget to regenerate and update the fstab with genfstab -U / > fstab and then adding nodatacow for the subvolume"
end

def pg_install
  ex = RemoteExecutor.new(SERVERS[:apex].hostname, ADMIN)
  ex.ssh('sudo pacman --noconfirm -S postgresql')
  ex.ssh("sudo -u #{PG} initdb #{ROOT_PATH}/data")
  ex.ssh('sudo systemctl enable --now  postgresql && sudo systemctl status postgresql')
  ex.ssh("sudo -u #{PG} psql -c \"ALTER USER #{PG} PASSWORD '#{PG_PASSWORD}';\"")
end

def pg_setup_databases
  ex = RemoteExecutor.new(SERVERS[:apex].hostname, ADMIN)
  PG_DBS.each do |name, v|
    puts "Setting up: #{name}"
    ex.ssh_seq([
                 "sudo -u #{PG} psql -c \"CREATE USER #{v.user} WITH PASSWORD '#{v.password}';\"",
                 "sudo -u #{PG} psql -c \"CREATE DATABASE #{v.db};\"",
                 "sudo -u #{PG} psql -c \"GRANT ALL PRIVILEGES ON DATABASE #{v.db} TO #{v.user};\"",
                 "sudo -u #{PG} psql -c \"ALTER DATABASE #{v.db} OWNER TO #{v.user}\""
               ])
    puts ''
  end
end
