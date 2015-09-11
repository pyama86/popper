# coding: utf-8
require 'octokit'
module Popper::Action
  class Ghe < Git
    def self.octkit
      Octokit.reset!
      Octokit.configure do |c|
        c.web_endpoint = Popper.configure.popper.ghe_url
        c.api_endpoint = File.join(Popper.configure.popper.ghe_url, "api/v3")
      end
      Octokit::Client.new(:access_token => Popper.configure.popper.ghe_token)
    end

    def self.check_params(config)
      my_conf(config).respond_to?(:repo) &&
      Popper.configure.popper.respond_to?(:ghe_url) &&
      Popper.configure.popper.respond_to?(:ghe_token)
    end

    next_action(Slack)
    action(:ghe)
  end
end
