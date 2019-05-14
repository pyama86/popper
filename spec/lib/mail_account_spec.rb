require 'spec_helper'
require 'slack-notifier'
require 'octokit'
describe Popper::MailAccount do
  describe 'run' do
    before do
      options = {}
      options[:config] = 'spec/fixture/popper_run.conf'
      options[:log] = '/tmp/popper.log'
      Popper.load_config(options)
      Popper.init_logger(options)

      allow_any_instance_of(Net::POP3).to receive(:start).and_yield(dummy_pop)

      ## exec command
      expect_any_instance_of(Object).to receive(:system).with(
        'test_command ' \
        'default_condition\ account_rule_condition_subject ' \
        "account_default_condition\\ account_rule_condition_body'\n' " \
        'no-reply@example.com ' \
        'example@example.com'
      ).and_return(true)

      # slack
      expect_any_instance_of(Slack::Notifier).to receive(:ping).with(
        "default_action_slack git:https://test.git.com/v3/issues/#123 ghe:https://test.ghe.com/v3/issues/#123",
        {
          attachments: [
            {
              pretext: "2015-09-10T16:20:10+09:00",
              title: "default_condition account_rule_condition_subject",
              color: "good"
            }
          ]
        }
      )

      # github
      allow_any_instance_of(Octokit::Client).to receive(:create_issue).with(
        "example/account_rule_action_git",
        "default_condition account_rule_condition_subject",
        "account_default_condition account_rule_condition_body\n",
        { labels: "first_gh_label,second_gh_label" }
      ).and_return(
        { html_url: "https://test.git.com/v3/issues/#123" }
      )

      # ghe
      allow_any_instance_of(Octokit::Client).to receive(:create_issue).with(
        "example/account_rule_action_ghe",
        "default_condition account_rule_condition_subject",
        "account_default_condition account_rule_condition_body\n",
        { labels: "first_ghe_label,second_ghe_label" }
      ).and_return(
        { html_url: "https://test.ghe.com/v3/issues/#123" }
      )

      @mail_account = described_class.new(Popper.configure.accounts.first)
      @mail_account.instance_variable_set(:@complete_list, [1])
    end

    it { expect(@mail_account.run).to be_truthy }
  end

  describe 'match_rules?' do
    before do
      options = {}
      options[:config] = 'spec/fixture/popper_match_rules.conf'
      options[:log] = '/tmp/popper.log'
      Popper.load_config(options)
      Popper.init_logger(options)
      @mail_account = described_class.new(Popper.configure.accounts.first)
    end

    it { expect(@mail_account.match_rules?(ok_mail)).to be_truthy }
    it { expect(@mail_account.match_rules?(match_multiple_rules).size).to eq(2) }
    it { expect(@mail_account.match_rules?(ng_subject_mail)).to be_empty }
    it { expect(@mail_account.match_rules?(ng_body_mail)).to be_empty }
  end
end

class Dummy
  def flock(type)
    true
  end
end

def dummy_pop
  pop = Object.new
  def pop.mails
    pop_mail = Net::POPMail.new(nil, nil, nil, nil)
    pop_mail.uid = 100

    def pop_mail.delete
      true
    end

    def pop_mail.mail
      <<-EOS
Delivered-To: example@example.com\r\nReceived: (qmail 5075 invoked from network); 10 Sep 2015 16:20:10 +0900\r\nTo: example@example.com\r\nSubject: default_condition account_rule_condition_subject\r\nFrom:no-reply@example.com\r\nMIME-Version: 1.0\r\nContent-Type: text/plain; charset=ISO-2022-JP\r\nContent-Transfer-Encoding: 7bit\r\nMessage-Id: <20150910072010.0545296845A@example.com>\r\nDate: Thu, 10 Sep 2015 16:20:10 +0900 (JST)\r\n\r\naccount_default_condition account_rule_condition_body
      EOS
    end
    [
      pop_mail
    ]
  end
  pop
end
