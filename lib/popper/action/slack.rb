require 'slack-notifier'
module Popper::Action
  class Slack < Base
    def self.task(config, mail, params={})
      notifier = ::Slack::Notifier.new(
        config.webhook_url,
        channel: config.channel,
        username: config.user || 'popper',
        link_names: 1
      )

      note = {
        pretext: mail.date.to_s,
        text: mail.subject,
        color: "good"
      }

      body = config.message || "popper mail notification"
      body += " #{config.mentions.join(" ")}" if config.mentions
      %w(
        git
        ghe
      ).each do |name|
        body += " #{name}:#{params[(name + '_url').to_sym]}" if params[(name + '_url').to_sym]
      end

      notifier.ping body, attachments: [note]
    end

    def self.check_params
      config.respond_to?(:channel) &&
      config.respond_to?(:webhook_url)
    end

    action(:slack)
  end
end
