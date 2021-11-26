require 'spec_helper'
require 'ostruct'

describe Popper::Action::Webhook do
  describe '.task' do
    before do
      options = {}
      options[:config] = 'spec/fixture/popper_run.conf'
      options[:log] = '/tmp/popper.log'
      Popper.load_config(options)
      Popper.init_logger(options)

      Popper::Action::Webhook.instance_variable_set(:@action_config, OpenStruct.new({ :webhook_url => 'http://localhost/webhook/event' }))

      allow_any_instance_of(Tempfile).to receive(:path).and_return("dummy")
      allow(Popper::Action::Webhook).to receive(:post!).and_return("ok")
    end

    it { expect(Popper::Action::Webhook.task(attach_mail)).to be_truthy }
  end
end
