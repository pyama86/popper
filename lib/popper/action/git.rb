# coding: utf-8
require 'octokit'
module Popper::Action
  class Git < Base
    def self.task(config, mail, params={})
      url = octkit.create_issue(
        my_conf(config).repo,
        mail.subject,
        mail.body.decoded.encode("UTF-8", mail.charset)
      )
      params["#{self.action}_url".to_sym] = url[:html_url] if url
      params
    end

    def self.octkit
      Octokit.reset!
      Octokit::Client.new(:access_token => Popper.configure.popper.git_token)
    end

    def self.check_params(config)
      my_conf(config).respond_to?(:repo) &&
      Popper.configure.popper.respond_to?(:git_token)
    end

    next_action(Ghe)
    action(:git)
  end
end
