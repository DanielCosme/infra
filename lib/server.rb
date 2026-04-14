# frozen_string_literal: true

module OS
  ARCH_LINUX = :arch_linux
  FEDORA = :fedora
  TRUE_NAS = :truenas
end

# Server
class Server
  attr_reader :ip, :hostname, :fqdn, :os

  def initialize(ip:, hostname:, fqdn:, is_public: false, os: OS::ARCH_LINUX)
    @ip = ip
    @hostname = hostname
    @is_public = is_public
    @fqdn = fqdn
    @os = os
  end

  def tailscale_domain
    "#{@hostname}.#{@fqdn}"
  end
end
