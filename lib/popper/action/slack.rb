require 'slack-notifier'
module Popper::Action
  class Slack < Base
    def self.task(mail, params={})
      notifier = ::Slack::Notifier.new(
        @action_config.webhook_url,
        channel: @action_config.channel,
        username: @action_config.user || 'popper',
        link_names: 1
      )

      note = {
        pretext: mail.date.to_s,
        title: mail.subject,
        color: "good"
      }
      note[:text] = mail_body(mail.utf_body) if @action_config.use_body

      body = @action_config.message || "popper mail notification"
      body += " #{@action_config.mentions.join(" ")}" if @action_config.mentions
      %w(
        git
        ghe
      ).each do |name|
        body += " #{name}:#{params[(name + '_url').to_sym]}" if params[(name + '_url').to_sym]
      end

      notifier.ping body, attachments: [note]
    end

    def self.check_params
      @action_config.respond_to?(:channel) &&
      @action_config.respond_to?(:webhook_url)
    end

    def self.mail_body(body)
      if @action_config.use_body.kind_of?(Integer) && body.lines.length > @action_config.use_body
        return body.lines[0, @action_config.use_body].push('--- snip ---').join
      end

      body
    end
  end
end
