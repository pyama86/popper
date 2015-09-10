require 'spec_helper'
describe Popper::Pop do

  describe 'match_rule?' do
    before do
      options = {}
      options[:config] = 'spec/fixture/popper.conf'
      Popper.load_config(options)
    end

    it { expect(described_class.match_rule?(Popper.configure.account.first, ok_mail)).to be_truthy }
    it { expect(described_class.match_rule?(Popper.configure.account.first, ng_body_mail)).to be_falsey }
    it { expect(described_class.match_rule?(Popper.configure.account.first, ng_mail)).to be_falsey }
  end
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
