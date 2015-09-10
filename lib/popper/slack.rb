require 'slack-notifier'
module Popper
  class Slack
    def self.run(config, mail)
      notifier = ::Slack::Notifier.new(
        Popper.configure.popper.slack_webhook_url,
        channel: config.channel,
        username: Popper.configure.popper.slack_user,
        link_names: 1
      )
      note = {
        pretext: mail.date,
        text: mail.subject,
        color: "good"
      }
      _message = config.message || "popper mail notification"
      _message << " " << config.mentions.join(" ") if config.mentions
      notifier.ping _message, attachments: [note]

    end
  end
end
