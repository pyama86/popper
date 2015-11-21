require 'net/pop'
require 'mail'
require 'kconv'

module Popper
  class MailAccount
    attr_accessor :protocol, :config, :complete_list

    def initialize(config)
      self.config = config
      self.protocol = Popper::Protocol::Pop.new(config)
    end

    def run
      protocol.session_start do
        self.complete_list = protocol.current_list unless complete_list
        check
      end
      rescue => e
        Popper.log.warn e
    end

    def check
      done_list = []
      error_list = []

      Popper.log.info "start popper #{config.name}"

      protocol.process_list(complete_list).each do |m|
        begin
          mail = protocol.get_mail(m)
          Popper.log.info "check mail:#{mail.date.to_s} #{mail.subject}"

          if rule = match_rule?(mail)
            Popper.log.info "do action:#{mail.subject}"
            Popper::Action::Git.run(config.action_by_rule(rule), mail) if config.action_by_rule(rule)
          end
          done_list << protocol.current_id

        rescue Popper::ConnectonError => e
          self.complete_list += done_list
          Popper.log.warn "err write session"
          return
        rescue => e
          error_list << protocol.current_id
          Popper.log.warn e
        end
      end

      self.complete_list = protocol.current_list - error_list
      Popper.log.info "success popper #{config.name}"
    end


    def match_rule?(mail)
      config.rule_with_conditions_find do |rule,mail_header,conditions|
        conditions.all? do |condition|
          mail.respond_to?(mail_header) && mail.send(mail_header).to_s.match(/#{condition}/)
        end
      end
    end
  end
end

class ::Hash
  def deep_merge(second)
    merger = proc { |key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : Array === v1 && Array === v2 ? v1 | v2 : [:undefined, nil, :nil].include?(v2) ? v1 : v2 }
    self.merge(second.to_h, &merger)
  end

  def deep_merge!(second)
    self.merge!(deep_merge(second))
  end
end

