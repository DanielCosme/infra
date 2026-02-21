# frozen_string_literal: true

# Postgres defines a Postgres connection info.
class Postgres
  attr_reader :db, :user, :password, :host

  def initialize(db:, user:, password:, host:)
    @db = db
    @user = user
    @password = password
    @host = host
  end
end
