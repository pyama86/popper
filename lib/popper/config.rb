require 'toml'
require 'ostruct'
require 'logger'
module Popper
  class Config
    attr_reader :popper, :default, :account
    def initialize(config_path)
      raise "configure not fond #{config_path}" unless File.exist?(config_path)

      config = TOML.load_file(config_path)
      @popper  = OpenStruct.new(config["popper"])
      @default = AccountAttributes.new(config["default"]) if config["default"]

      @account = []

      config.select {|k,v| !%w(popper default).include?(k) }.each do |profile|
        _profile = AccountAttributes.new(profile[1])
        _profile.name = profile[0]
        @account << _profile
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
  end

  def self.load_config(options)
    config_path = options[:config] || File.join(Dir.home, "popper", "popper.conf")
    @_config = Config.new(config_path)
  end

  def self.configure
    @_config
  end
end
