require 'spec_helper'
require 'slack-notifier'
require 'octokit'
describe Popper::Pop do
  before do
    options = {}
    options[:config] = 'spec/fixture/popper.conf'
    Popper.load_config(options)
    Popper.init_logger(options)
    allow_any_instance_of(Logger).to receive(:info).and_return(true)
    allow_any_instance_of(Logger).to receive(:warn).and_return(true)
  end

  describe 'run' do
    before do
      allow(Net::POP3).to receive(:start).and_yield(dummy_pop)
      expect_any_instance_of(Slack::Notifier).to receive(:ping).with(
        "test message @test git:https://test.git.com/v3/issues/#123",
        {
          attachments: [
            {
              pretext: "2015-09-10T16:20:10+09:00",
              text: "test example subject",
              color: "good"
            }
          ]
        }
      )

      expect_any_instance_of(Octokit::Client).to receive(:create_issue).with(
        "test/example",
        "test example subject",
        "test example body\n",
      ).and_return(
        { html_url: "https://test.git.com/v3/issues/#123" }
      )
    end

    it { expect(described_class.run).to be_truthy }
  end

  describe 'match_rule?' do
    it { expect(described_class.match_rule?(Popper.configure.account.first, ok_mail)).to be_truthy }
    it { expect(described_class.match_rule?(Popper.configure.account.first, ng_body_mail)).to be_falsey }
    it { expect(described_class.match_rule?(Popper.configure.account.first, ng_mail)).to be_falsey }
  end
end

def dummy_pop
  pop = Object.new
  def pop.mails
    pop_mail = Net::POPMail.new(nil, nil, nil, nil)
    pop_mail.uid = 100

    def pop_mail.mail
      <<-EOS
Delivered-To: example@example.com\r\nReceived: (qmail 5075 invoked from network); 10 Sep 2015 16:20:10 +0900\r\nTo: example@example.com\r\nSubject: test example subject\r\nFrom:no-reply@example.com\r\nMIME-Version: 1.0\r\nContent-Type: text/plain; charset=ISO-2022-JP\r\nContent-Transfer-Encoding: 7bit\r\nMessage-Id: <20150910072010.0545296845A@example.com>\r\nDate: Thu, 10 Sep 2015 16:20:10 +0900 (JST)\r\n\r\ntest example body
      EOS
    end
    [
      pop_mail
    ]
  end
  pop
end



def ok_mail
  mail = Mail.new
  mail.subject = "test example subject"
  mail.body    = "test example word"
  mail
end

def ng_body_mail
  mail = Mail.new
  mail.subject = "test example subject"
  mail.body    = "test nomatch word"
  mail
end

def ng_mail
  mail = Mail.new
  mail.subject = "test nomatch subject"
  mail.body    = "test nomatch word"
  mail
end
