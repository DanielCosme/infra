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

  def host
    "#{@hostname}.#{@fqdn}"
  end
end
