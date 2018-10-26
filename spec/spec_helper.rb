require 'popper'


RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end


def ok_mail
  mail = EncodeMail.new
  mail.subject = "test ok"
  mail.body    = "test ok"
  mail
end

def ng_body_mail
  mail = EncodeMail.new
  mail.subject = "test ok"
  mail.body    = "test ng"
  mail
end

def ng_subject_mail
  mail = EncodeMail.new
  mail.subject = "test ng"
  mail.body    = "test ok"
  mail
end

def match_multiple_rules
  mail = EncodeMail.new
  mail.subject = "test ok"
  mail.body    = "test match multiple rule"
  mail
end

def attach_mail
  mail = EncodeMail.new
  mail.from = "test@example.com"
  mail.to = "test@example.com"
  mail.subject = "test ok"
  mail.body    = "test ok"
  mail.add_file('spec/fixture/attach1.jpg')
  mail.add_file('spec/fixture/attach2.jpg')
  mail
end
