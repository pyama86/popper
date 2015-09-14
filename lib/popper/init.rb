module Popper
  class Init
    def self.run(options)
      dirname = options[:config] || File.join(Dir.home, "popper")
      unless FileTest.exist?(dirname)
        FileUtils.mkdir_p(dirname)
        open("#{dirname}/popper.conf","w") do |e|
          e.puts sample_config
        end if FileTest.exist?(dirname)
        puts "create directry ~/popper"
      end
    end

    def self.sample_config
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

[default.condition]
subject = ["^(?!.*Re:).+$"]

[default.action.slack]
webhook_url = "webhook_url"
user = "slack"
channel = "#default_channel"
message = "default message"

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
