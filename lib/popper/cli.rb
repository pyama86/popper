require 'popper'
require 'thor'

module Popper
  class CLI < Thor
    class_option :config, type: :string, aliases: '-c'
    class_option :log, type: :string, aliases: '-l'
    class_option :daemon, type: :boolean, aliases: '-d'
    class_option :pidfile, type: :string, aliases: '-p', default: '/var/run/popper.pid'
    default_task :pop
    desc "pop", "from pop3"
    def pop
      Popper.init_logger(options)
      Popper.load_config(options)

      if(options[:daemon])
        Process.daemon
        open(options[:pid_file], 'w') {|f| f << Process.pid}
        Popper::Pop.prepop
        while true
          sleep(60 || Popper.configure.global.interval)
          Popper::Pop.run
        end
      end
      Popper::Pop.run
      rescue => e
        Popper.log.fatal(e)
        Popper.log.fatal(e.backtrace)
    end

    desc "prepop", "get current mailbox all uidl"
    def prepop
      Popper.init_logger(options, true)
      Popper.load_config(options)
      Popper::Pop.prepop
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
  end
end
