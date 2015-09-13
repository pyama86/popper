require 'slack-notifier'
module Popper::Action
  class Slack < Base
    def self.task(config, mail, params={})
      notifier = ::Slack::Notifier.new(
        my_config.webhook_url,
        channel: my_config.channel,
        username: my_config.user || 'popper',
        link_names: 1
      )

      note = {
        pretext: mail.date.to_s,
        text: mail.subject,
        color: "good"
      }

      body = my_config.message || "popper mail notification"
      body += " #{my_config.mentions.join(" ")}" if my_config.mentions
      %w(
        git
        ghe
      ).each do |name|
        body += " #{name}:#{params[(name + '_url').to_sym]}" if params[(name + '_url').to_sym]
      end

      notifier.ping body, attachments: [note]
    end

    def self.check_params
      my_config.respond_to?(:channel) &&
      my_config.respond_to?(:webhook_url)
    end

    action(:slack)
  end
end
