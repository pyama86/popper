require 'slack-notifier'
module Popper::Action
  class Slack < Base
    def self.task(config, mail, params={})
      notifier = ::Slack::Notifier.new(
        Popper.configure.popper.slack_webhook_url,
        channel: my_conf(config).channel,
        username: Popper.configure.popper.slack_user,
        link_names: 1
      )

      note = {
        pretext: mail.date.to_s,
        text: mail.subject,
        color: "good"
      }

      body = my_conf(config).message || "popper mail notification"
      body += " #{my_conf(config).mentions.join(" ")}" if my_conf(config).mentions

      %w(
        git
        ghe
      ).each do |name|
        body += " #{name}:#{params[(name + '_url').to_sym]}" if params[(name + '_url').to_sym]
      end

      notifier.ping body, attachments: [note]
    end

    def self.check_params(config)
      my_conf(config).respond_to?(:channel) &&
      Popper.configure.popper.respond_to?(:slack_webhook_url) &&
      Popper.configure.popper.respond_to?(:slack_user)
    end

    action(:slack)
  end
end
