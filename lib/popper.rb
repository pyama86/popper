require 'pp'
require "popper/version"
require "popper/cli"
require 'popper/pop'
require "popper/config"
require "popper/action"
require "popper/init"

module Popper
  def self.init_logger(options)
    log_path = options[:log] || File.join(Dir.home, "popper", "popper.log")
    @_logger = Logger.new(log_path)
  end

  def self.log
    @_logger
  end
end
