# frozen_string_literal: true

require 'net/ssh'
require 'net/scp'

# RemoteExecutor
class RemoteExecutor
  def initialize(host, user, opts = {})
    @host = host
    @user = user
    @opts = opts
  end

  def ssh(cmd, print: true)
    do_one(cmd, should_fail: false, print: print)
  end

  def ssh_f(cmd, print: true)
    do_one(cmd, should_fail: true, print: print)
  end

  def ssh_seq(cmds, print: true)
    do_seq(cmds, should_fail: false, print: print)
  end

  def ssh_seq_f(cmds, print: true)
    do_seq(cmds, should_fail: true, print: print)
  end

  def scp(from:, to:)
    Net::SCP.start(@host, @user, @opts) do |scp|
      ok = scp.upload!(from, to)
      abort 'upload failed' unless ok
    end
  end

  private

  def do_seq(cmds, should_fail:, print:)
    Net::SSH.start(@host, @user, @opts) do |ssh|
      cmds.each do |cmd|
        res = ssh.exec!(cmd)
        puts res if print && !res.empty?
        abort "exit: #{res.exitstatus}" if should_fail && res.exitstatus.positive?
      end
    end
  end

  def do_one(cmd, should_fail:, print:)
    Net::SSH.start(@host, @user, @opts) do |ssh|
      res = ssh.exec!(cmd)
      puts res if print && !res.empty?
      abort "exit: #{res.exitstatus}" if should_fail && res.exitstatus.positive?
      return res
    end
  end
end
