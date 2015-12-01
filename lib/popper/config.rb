require 'toml'
require 'ostruct'
require 'logger'
module Popper
  class Config
    attr_reader :global, :default, :accounts
    def initialize(config_path)
      raise "configure not fond #{config_path}" unless File.exist?(config_path)
      config = TOML.load_file(config_path)
      if config.key?("include")
        content = config["include"].map {|p| Dir.glob(p).map {|f|File.read(f)}}.join("\n")
        config.delete("include")
        config.deep_merge!(TOML::Parser.new(content).parsed)
      end

      @global  = AccountAttributes.new(config["global"]) if config["global"]
      @default = AccountAttributes.new(config["default"]) if config["default"]
      @accounts = []

      config.select {|k,v| !%w(default global).include?(k) }.each do |account|
        _account = AccountAttributes.new(account[1])
        _account.name = account[0]
        self.accounts << _account
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

    [
      %w(find all?),
      %w(each each),
    ].each do |arr|
      define_method("rule_with_conditions_#{arr[0]}") do |&blk|
        self.rules.to_h.keys.send(arr[0]) do |rule|
          self.condition_by_rule(rule).to_h.send(arr[1]) do |mail_header,conditions|
            blk.call(rule, mail_header, conditions)
          end
        end
      end
    end

    %w(
      condition
      action
    ).each do |name|
      define_method("global_default_#{name}") {
        begin
          Popper.configure.default.send(name).to_h
        rescue
          {}
        end
      }

      define_method("account_default_#{name}") {
        begin
          self.default.send(name).to_h
        rescue
          {}
        end
      }

      # merge global default and account default
      define_method("#{name}_by_rule") do |rule|
        hash = self.send("global_default_#{name}")
        hash = hash.deep_merge(self.send("account_default_#{name}").to_h) if self.send("account_default_#{name}")
        hash = hash.deep_merge(self.rules.send(rule).send(name).to_h) if rules.send(rule).respond_to?(name.to_sym)

        # replace body to utf_body
        AccountAttributes.new(Hash[hash.map {|k,v| [k.to_s.gsub(/^body$/, "utf_body").to_sym, v]}])
      end
    end
  end

  def self.load_config(options)
    config_path = options[:config] || "/etc/popper.conf"
    @_config = Config.new(config_path)
  end

  def self.configure
    @_config
  end
end
