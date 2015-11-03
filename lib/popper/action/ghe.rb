# coding: utf-8
require 'octokit'
module Popper::Action
  class Ghe < Git
    def self.octkit
      Octokit.reset!
      Octokit.configure do |c|
        c.web_endpoint = @action_config.url
        c.api_endpoint = File.join(@action_config.url, "api/v3")
      end
      Octokit::Client.new(:access_token => @action_config.token)
    end

    def self.check_params
      @action_config.respond_to?(:url) && super
    end

    next_action(Slack)
    action(:ghe)
  end
end
