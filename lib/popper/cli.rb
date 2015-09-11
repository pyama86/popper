require 'popper'
require 'thor'

module Popper
  class CLI < Thor
    class_option :config, type: :string, aliases: '-c'
    class_option :log, type: :string, aliases: '-l'
    default_task :pop
    desc "pop", "from pop3"
    def pop
      Popper.load_config(options)
      Popper.init_logger(options)
      Popper::Pop.run
      rescue => e
        Popper.log.fatal(e)
        Popper.log.fatal(e.backtrace)
    end

    map %w[--version -v] => :__print_version
    desc "--version, -v", "print the version"
    def __print_version
      puts "Popper version:#{Popper::VERSION}"
    end
  end
end
