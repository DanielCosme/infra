# frozen_string_literal: true

require_relative '../lib/server'

USER = 'daniel'
ADMIN = 'arch'
FEDORA_ADMIN = 'fedora'
TIMEZONE = 'America/Montreal'

TAILSCALE_DOMAIN = 'orca-uaru.ts.net'
SECRETS_PATH = './config/secrets'
ENC_SECRETS_PATH = './config/enc'
DATAPOOL_PATH = '/datapool'
GIT_URL = 'https://git.danicos.dev'
APEX_BTRFS_DEVICE = '/dev/sdd'

SERVERS = {
  ape0: Server.new(
    ip: '138.197.161.200',
    hostname: 'ape-0',
    is_public: true,
    fqdn: TAILSCALE_DOMAIN
  ),
  apex: Server.new(
    ip: '10.0.0.59', # Must be in the local network for this IP to work. For the rest of operations, Tailscale is used.
    hostname: 'apex',
    fqdn: TAILSCALE_DOMAIN
  ),
  charlie: Server.new(
    ip: '148.113.201.167',
    hostname: 'charlie',
    is_public: true,
    fqdn: TAILSCALE_DOMAIN
  )
}.freeze

SERVER_LIST = [
  SERVERS[:ape0],
  SERVERS[:apex],
  SERVERS[:charlie]
].freeze

SERVER = SERVERS[:ape0]
