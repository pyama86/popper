require 'toml'
require 'ostruct'
require 'logger'
module Popper
  class Config
    attr_reader :default, :accounts, :interval

    def initialize(config_path)
      raise "configure not fond #{config_path}" unless File.exist?(config_path)

      config = read_file(config_path)

      @interval = config.key?('interval') ? config['interval'].to_i : 60
      @default = config['default'] if config['default']
      @accounts = config.select { |_k, v| v.is_a?(Hash) && v.key?('login') }.map do |account|
        _account = AccountAttributes.new(account[1])
        _account.name = account[0]
        _account
      end
    end

    def read_file(file)
      config = TOML.load_file(file)
      if config.key?('include')
        content = config['include'].map { |p| Dir.glob(p).map { |f| File.read(f) } }.join("\n")
        config.deep_merge!(TOML::Parser.new(content).parsed)
      end
      config
    end

    %w[
      condition
      action
    ].each do |name|
      define_method("default_#{name}") do
        default[name]
      rescue StandardError
        {}
      end
    end
  end

  class AccountAttributes < OpenStruct
    def initialize(hash = nil)
      super
      @table = {}
      @hash = hash

      if hash
        hash.each do |k, v|
          @table[k.to_sym] = (v.is_a?(Hash) ? self.class.new(v) : v)
        end
      end
    end

    def to_h
      @hash
    end

    [
      %w[select all?],
      %w[each each]
    ].each do |arr|
      define_method("rule_with_conditions_#{arr[0]}") do |&blk|
        @hash['rules'].keys.send(arr[0]) do |rule|
          condition_by_rule(rule).to_h.send(arr[1]) do |mail_header, conditions|
            blk.call(rule, mail_header, conditions)
          end
        end
      end
    end

    %w[
      condition
      action
    ].each do |name|
      define_method("account_default_#{name}") do
        @hash['default'][name]
      rescue StandardError
        {}
      end

      # merge default and account default
      define_method("#{name}_by_rule") do |rule|
        hash = Popper.configure.send("default_#{name}")
        hash = hash.deep_merge(send("account_default_#{name}")) if send("account_default_#{name}")
        hash = hash.deep_merge(rule_by_name(rule)[name]) if rule_by_name(rule).key?(name)

        # replace body to utf_body
        AccountAttributes.new(Hash[hash.map { |k, v| [k.to_s.gsub(/^body$/, 'utf_body').to_sym, v] }])
      end
    end

    def rule_by_name(name)
      @hash['rules'][name]
    rescue StandardError
      {}
    end
  end

  def self.load_config(options)
    config_path = options[:config] || '/etc/popper.conf'
    @_config = Config.new(config_path)
  end

  def self.configure
    @_config
  end
end
