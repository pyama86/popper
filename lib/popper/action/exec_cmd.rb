require 'bundler'
require 'tempfile'
module Popper::Action
  class ExecCmd < Base
    def self.task(mail, params={})
      tmps = mail.attachments.map do |a|
        ::Tempfile.open(a.filename) do |f|
          f.write a.body.decoded
          f
        end
      end unless mail.attachments.empty?
      cmd = "#{@action_config.cmd} '#{mail.subject}' '#{mail.utf_body}' '#{mail.from.join(";")}' '#{mail.to.join(";")}'"
      cmd += " #{tmps.map {|t| "'#{t.path}'"}.join(' ')}" if tmps

      ::Bundler.with_clean_env do
        system(cmd)
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
