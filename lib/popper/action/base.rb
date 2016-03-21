module Popper::Action
  class Base
    @next_action = nil
    @action_config = nil

    def self.run(config, mail, params={})
      @action_config = config.send(action_name) if config.respond_to?(action_name)
      begin
        Popper.log.info "run action #{action_name}"
        params = task(mail, params)
        Popper.log.info "exit action #{action_name}"
      rescue => e
        Popper.log.warn e
        Popper.log.warn e.backtrace
      end if do_action?
      next_run(config, mail, params)
    end

    def self.next_action(action=nil)
      @next_action = action if action
      @next_action
    end

    def self.next_run(config, mail, params={})
      @next_action.run(config, mail, params) if @next_action
    end

    def self.do_action?
      @action_config && check_params
    end

    def self.action_name
      self.name.split('::').last.downcase.to_sym
    end



    def self.check_params; end
  end
end
