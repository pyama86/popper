
require 'spec_helper'
require 'ostruct'
describe Popper::Action::ExecCmd do
  describe '.task' do
    before do
      options = {}
      options[:config] = 'spec/fixture/popper_run.conf'
      options[:log] = '/tmp/popper.log'
      Popper.load_config(options)
      Popper.init_logger(options)

      Popper::Action::ExecCmd.instance_variable_set(:@action_config,  OpenStruct.new({ :cmd => true }))

      allow_any_instance_of(Tempfile).to receive(:path).and_return("dummy")
      expect_any_instance_of(Object).to receive(:system).with(
        "true " \
        "'test ok' " \
        "'test ok' " \
        "'test@example.com' " \
        "'test@example.com' " \
        "'dummy' " \
        "'dummy'"
      ).and_return(true)
    end

    it { expect(Popper::Action::ExecCmd.task(attach_mail)).to be_truthy }
  end
end
