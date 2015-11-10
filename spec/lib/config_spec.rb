require 'spec_helper'
require 'slack-notifier'
require 'octokit'
describe Popper::Config do
  before do
    options = {}
    options[:config] = 'spec/fixture/popper_config_test.conf'
    Popper.load_config(options)
  end

  context 'global' do
    it { expect(Popper.configure.global.interval).to eq 60 }
  end

  context 'condition' do
    it { expect(Popper.configure.accounts.first.condition_by_rule("test_rule").subject).to eq ["^(?!.*Re:).+$", ".*account_rule_subject.*"] }
    it { expect(Popper.configure.accounts.first.condition_by_rule("test_rule").utf_body).to eq [".*account_default_body.*"] }
    it { expect(Popper.configure.accounts.last.condition_by_rule("test_rule").subject).to eq ["^(?!.*Re:).+$", ".*account_rule_subject_2.*"] }
    it { expect(Popper.configure.accounts.last.condition_by_rule("test_rule").utf_body).to eq [".*account_default_body_2.*"] }
  end

  context 'action' do
    it { expect(Popper.configure.accounts.first.action_by_rule("test_rule").ghe.token).to eq "test_token" }
    it { expect(Popper.configure.accounts.first.action_by_rule("test_rule").ghe.url).to eq "https://ghe.example.com" }
    it { expect(Popper.configure.accounts.first.action_by_rule("test_rule").ghe.repo).to eq "example/rule" }
    it { expect(Popper.configure.accounts.last.action_by_rule("test_rule").ghe.token).to eq "test_token" }
    it { expect(Popper.configure.accounts.last.action_by_rule("test_rule").ghe.url).to eq "https://2.ghe.example.com" }
    it { expect(Popper.configure.accounts.last.action_by_rule("test_rule").ghe.repo).to eq "example/rule_2" }
  end
end
