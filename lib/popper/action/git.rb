# coding: utf-8
require 'octokit'
module Popper::Action
  class Git < Base
    def self.run(config, mail, params={})
      if action?(config)
        url = octkit.create_issue(my_conf(config).repo, mail.subject.force_encoding('utf-8'), mail.body.to_s.force_encoding('utf-8'))
      end
      params["#{self.action}_url".to_sym] = url[:html_url] if url
      next_run(config, mail, params)
    end

    def self.octkit
      Octokit.reset!
      Octokit::Client.new(:access_token => Popper.configure.popper.git_token)
    end

    def self.check_params(config)
      my_conf(config).respond_to?(:repo) && Popper.configure.popper.respond_to?(:git_token)
    end

    next_action(Ghe)
    action(:git)
  end
end
