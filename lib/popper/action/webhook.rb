module Popper::Action
  class Webhook < Base
    def self.task(mail, params = {})
      post!(@action_config.webhook_url, mail.subject, mail.utf_body)

      params
    end

    def self.check_params
      @action_config.respond_to?(:webhook_url)
    end

    def self.post!(url, subject, body)
      request_body = { subject: subject, body: body }.to_json

      Faraday.post(
        url,
        request_body,
        "Content-Type" => "application/json"
      )
    end

    next_action(ExecCmd)
  end
end
