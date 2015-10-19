module Popper
  class Init
    def self.run(options)
      filename = options[:config] || "/etc/popper.conf"
      unless FileTest.exist?(filename)
        open(filename,"w") do |e|
          e.puts sample_config
        end
        puts "create sample config #{filename}"
      end
    end

    def self.sample_config
      <<-EOS
[global]
interval = 60       # fetch interbal default:60
work_dir = /var/tmp # working directory

[default.condition]
subject = ["^(?!.*Re:).+$"]

[default.action.slack]
webhook_url = "webhook_url"
user = "slack"
channel = "#default_channel"
message = "default message"

[example.login]
server = "mail.examplejp"
user = "examplle_user"
password = "examplle_pass"

[example.default.condition]
subject = [".*default.*"]

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
