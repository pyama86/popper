require 'popper'
require 'thor'

module Popper
  class CLI < Thor
    class_option :config, type: :string, aliases: '-c'
    class_option :log, type: :string, aliases: '-l'
    class_option :daemon, type: :boolean, aliases: '-d'
    class_option :pidfile, type: :string, aliases: '-p'
    default_task :pop
    desc "pop", "from pop3"
    def pop
      if(options[:daemon])
        Popper.init_logger(options)
        Process.daemon
        open(options[:pidfile] || "/var/run/popper.pid" , 'w') {|f| f << Process.pid}
      else
        Popper.init_logger(options, true)
      end

      Popper.load_config(options)

      accounts = Popper.configure.accounts.map {|account| MailAccount.new(account)}
      while true
        accounts.each(&:run)
        sleep(60 || Popper.configure.global.interval)
      end

      rescue => e
        Popper.log.fatal(e)
        Popper.log.fatal(e.backtrace)
    end

    class_option :config, type: :string, aliases: '-c'
    desc "config", "show configure"
    def config
      Popper.load_config(options)
      Popper.configure.accounts.each do |account|
        print_config(account)
      end
    end

    desc "init", "create home dir"
    def init
      Popper::Init.run(options)
      rescue => e
        puts e
        puts e.backtrace
    end

    map %w[--version -v] => :__print_version
    desc "--version, -v", "print the version"
    def __print_version
      puts "Popper version:#{Popper::VERSION}"
    end

    no_commands do
      def print_config(config)
        puts config.name
        last_rule = nil
        last_header = nil

        config.rule_with_conditions_all? do |rule,mail_header,condition|
          puts " "*1 + "rule[#{rule}]" if rule != last_rule
          puts " "*2 + "actions" if rule != last_rule

          config.action_by_rule(rule).each_pair do |action,params|
            puts " "*3 + "#{action}"
            params.each_pair do |k,v|
              puts " "*4 + "#{k} #{v}"
            end
          end if rule != last_rule

          puts " "*2 + "header[#{mail_header}]" if mail_header != last_header
          puts " "*3 + "#{condition}"

          last_rule = rule
          last_header = mail_header
          true
        end
      end
    end
  end
end
