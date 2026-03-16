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
    ip: '10.0.0.57', # Local IP
    hostname: 'apex-truenas',
    is_public: false,
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
  SERVERS[:apexnas],
  SERVERS[:charlie]
].freeze

SERVER = SERVERS[:charlie]
