require 'toml'
require 'ostruct'
require 'logger'
module Popper
  class Config
    attr_reader :default, :accounts
    def initialize(config_path)
      raise "configure not fond #{config_path}" unless File.exist?(config_path)

      config = TOML.load_file(config_path)
      @default = AccountAttributes.new(config["default"]) if config["default"]
      @accounts = []

      config.select {|k,v| !%w(default).include?(k) }.each do |account|
        _account = AccountAttributes.new(account[1])
        _account.name = account[0]
        @accounts << _account
      end
    end

  end

  class AccountAttributes < OpenStruct
    def initialize(hash=nil)
      @table = {}
      @hash_table = {}

      if hash
        hash.each do |k,v|
          @table[k.to_sym] = (v.is_a?(Hash) ? self.class.new(v) : v)
          @hash_table[k.to_sym] = v
          new_ostruct_member(k)
        end
      end
    end

    def to_h
      @hash_table
    end

    def action_by_rule(rule)
      self.rules.send(rule).action if rules.send(rule).respond_to?(:action)
    end

    def condition_by_rule(rule)
      self.rules.send(rule).condition if rules.send(rule).respond_to?(:condition)
    end
  end

  def self.load_config(options)
    config_path = options[:config] || File.join(Dir.home, "popper", "popper.conf")
    @_config = Config.new(config_path)
  end

  def self.configure
    @_config
  end
end
