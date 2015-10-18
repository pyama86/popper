require 'pp'
require "popper/version"
require "popper/cli"
require 'popper/pop'
require "popper/config"
require "popper/action"
require "popper/init"
require "popper/sync"

module Popper
  def self.init_logger(options, stdout=nil)
    log_path = options[:log] || File.join(Dir.home, "popper", "popper.log")
    log_path = STDOUT if ENV["POPPER_TEST"] || stdout
    @_logger = Logger.new(log_path)
  rescue => e
    puts e
  end

  def self.log
    @_logger
  end
end
