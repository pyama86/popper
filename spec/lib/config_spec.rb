require 'spec_helper'
require 'slack-notifier'
require 'octokit'
describe Popper::Config do
  before do
    options = {}
    options[:config] = 'spec/fixture/popper_config_test.conf'
    Popper.load_config(options)
  end

  context 'condition' do
    it { expect(Popper.configure.accounts.first.condition_by_rule("normal_log").subject).to eq ["^(?!.*Re:).+$", ".*example.*"] }
    it { expect(Popper.configure.accounts.first.condition_by_rule("normal_log").body).to eq [".*account default body.*", ".*example.*"] }
    it { expect(Popper.configure.accounts.first.condition_by_rule("error_log").subject).to eq ["^(?!.*Re:).+$", ".*example2.*"] }
    it { expect(Popper.configure.accounts.first.condition_by_rule("error_log").body).to eq [".*account default body.*", ".*example2.*"] }
  end

  context 'action' do
    it { expect(Popper.configure.accounts.first.action_by_rule("error_log").git.token).to eq "account_default_token" }
    it { expect(Popper.configure.accounts.first.action_by_rule("error_log").slack.channel).to eq "#example_2" }
  end
end
