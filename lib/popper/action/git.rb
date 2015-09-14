# coding: utf-8
require 'octokit'
module Popper::Action
  class Git < Base
    def self.task(config, mail, params={})
      url = octkit.create_issue(
        my_config.repo,
        mail.subject,
        mail.body
      )
      params["#{self.action}_url".to_sym] = url[:html_url] if url
      params
    end

    def self.octkit
      Octokit.reset!
      Octokit::Client.new(:access_token => my_config.token)
    end

    def self.check_params
      my_config.respond_to?(:repo) &&
      my_config.respond_to?(:token)
    end

    next_action(Ghe)
    action(:git)
  end
end
