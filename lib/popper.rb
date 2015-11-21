require 'pp'
require "popper/version"
require "popper/cli"
require 'popper/mail_account'
require "popper/config"
require "popper/action"
require "popper/init"
require "popper/popper_error"
require "popper/protocol"

module Popper
  def self.init_logger(options, stdout=nil)
    log_path = options[:log] || "/var/log/popper.log"
    log_path = STDOUT if ENV["POPPER_TEST"] || stdout
    @_logger = Logger.new(log_path)
  rescue => e
    puts e
  end

  def self.log
    @_logger
  end
end
