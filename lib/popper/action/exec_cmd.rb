module Popper::Action
  class ExecCmd < Base
    def self.task(mail, params={})
      ::Bundler.with_clean_env do
        system("#{@action_config.cmd} '#{mail.subject}' '#{mail.utf_body}' '#{mail.from.join(";")}' '#{mail.to.join(";")}'")
      end
      params
    end

    def self.check_params
      @action_config.respond_to?(:cmd)
    end

    def self.action_name
      :exec_cmd
    end

    next_action(Git)
  end
end
