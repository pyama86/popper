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

    desc "prepop", "get current mailbox all uidl"
    def prepop
      Popper.load_config(options)
      Popper::Pop.prepop
    end

    desc "init", "create home dir"
    def init
      create_home_dir
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
      def create_home_dir
        dirname = options[:config] || File.join(Dir.home, "popper")
        unless FileTest.exist?(dirname)
          FileUtils.mkdir_p(dirname)
          open("#{dirname}/popper.conf","w") do |e|
            e.puts sample_config
          end if FileTest.exist?(dirname)
          puts "create directry ~/popper"
        end
      end

      def sample_config
        <<-EOS
[popper]
slack_webhook_url = "https://test.slack.com"
slack_user = "popper"
git_token = "test"
ghe_token = "test"
ghe_url = "http://ghe.example.com"

[example.login]
server = "mail.examplejp"
user = "examplle_user"
password = "examplle_pass"

[example.rules.normal_log.condition]
subject = ".*example.*"
body = ".*example.*"

[example.rules.normal_log.action.slack]
channel = "#test"
mentions = ["@test"]
message = "test message"

[example.rules.normal_log.action.git]
repo = "test/example"

[example.rules.normal_log.action.ghe]
repo = "test/example"
        EOS
      end
    end
  end
end
