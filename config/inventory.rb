# frozen_string_literal: true

require_relative '../lib/server'

USER = 'daniel'
ADMIN = 'arch'
FEDORA_ADMIN = 'fedora'
TIMEZONE = 'America/Montreal'
TAILSCALE_DOMAIN = 'orca-uaru.ts.net'

SECRETS_PATH = './config/secrets'
ENC_SECRETS_PATH = './config/enc'
GIT_URL = 'https://git.danicos.dev'

SERVERS = {
  apexnas: Server.new(
    ip: '10.0.0.57', # LAN IP
    hostname: 'apex-truenas',
    is_public: false,
    fqdn: TAILSCALE_DOMAIN,
    os: OS::TRUE_NAS
  ),
  charlie: Server.new(
    ip: '148.113.201.167', # Public IP
    hostname: 'charlie',
    is_public: true,
    fqdn: TAILSCALE_DOMAIN,
    os: OS::FEDORA
  ),
  hydra0: Server.new(
    # ip: '10.0.0.171',
    ip: '100.93.39.59', # Tailscale IP
    hostname: 'hydra-0',
    is_public: false,
    fqdn: TAILSCALE_DOMAIN,
    os: OS::ARCH_LINUX
  )
}.freeze

SERVER_LIST = [
  SERVERS[:apexnas],
  SERVERS[:charlie],
  SERVERS[:hydra0]
].freeze

HYDRA_CLUSTER = [
  SERVERS[:hydra0]
].freeze

SERVER = SERVERS[:hydra0]
