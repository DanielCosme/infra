# frozen_string_literal: true

# Server
class Server
  attr_reader :ip, :hostname, :fqdn

  def initialize(ip:, hostname:, fqdn:, is_public: false)
    @ip = ip
    @hostname = hostname
    @is_public = is_public
    @fqdn = fqdn
  end

  def tailscale_domain
    "#{@hostname}.#{@fqdn}"
  end
end
