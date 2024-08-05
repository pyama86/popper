require 'bundler'
require 'shellwords'
require 'tempfile'
module Popper::Action
  class ExecCmd < Base
    def self.task(mail, params = {})
      unless mail.attachments.empty?
        tmps = mail.attachments.map do |a|
          ::Tempfile.open(a.filename) do |f|
            f.write a.body.decoded
            f
          end
        end
      end
      cmd = "#{@action_config.cmd} #{Shellwords.escape(mail.subject)} #{Shellwords.escape(mail.utf_body)} #{Shellwords.escape(mail.from.join(';'))} #{Shellwords.escape(mail.to.join(';'))}"
      cmd += " #{tmps.map { |t| Shellwords.escape(t.path) }.join(' ')}" if tmps && !tmps.empty?
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
