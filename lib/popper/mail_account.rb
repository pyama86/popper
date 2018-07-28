require 'net/pop'
require 'mail'
require 'kconv'

module Popper
  class MailAccount
    attr_accessor :config, :current_list, :complete_list

    def initialize(config)
      self.config = config
    end

    def run
      session_start do |conn|
        self.current_list = conn.mails.map(&:uidl)
        self.complete_list = current_list unless complete_list
        pop(conn)
      end
      rescue => e
        Popper.log.warn e
    end

    def pop(conn)
      done_uidls = []
      error_uidls = []

      Popper.log.info "start popper #{config.name}"

      process_uidl_list(conn).each do |m|
        begin
          done_uidls << check_and_action(m)
          m.delete if config.login.respond_to?(:delete_after) && config.login.delete_after
        rescue Net::POPError => e
          self.complete_list += done_uidls
          Popper.log.warn "pop err write uidl"
          return
        rescue => e
          error_uidls << m.uidl
          Popper.log.warn e
        end
      end

      self.complete_list = current_list - error_uidls
      Popper.log.info "success popper #{config.name}"
    end

    def check_and_action(m)
      mail = EncodeMail.new(m.mail)
      Popper.log.info "check mail:#{mail.date.to_s} #{mail.subject}"
      rules = match_rule?(mail)
      rules.each do |rule|
        Popper.log.info "do action:#{mail.subject}"
        Popper::Action::ExecCmd.run(config.action_by_rule(rule), mail) if config.action_by_rule(rule)
      end

      m.uidl
    end

    def session_start(&block)
      pop = Net::POP3.new(config.login.server, config.login.port || 110)
      pop = set_pop_option(pop)

      pop.start(
        config.login.user,
        config.login.password
      ) do |conn|
        Popper.log.info "connect server #{config.name}"
        block.call(conn)
        Popper.log.info "disconnect server #{config.name}"
      end
    end

    def set_pop_option(pop)
      pop.enable_ssl if config.login.respond_to?(:ssl) && config.login.ssl
      %w(
        open_timeout
        read_timeout
      ).each do |m|
        pop.instance_variable_set("@#{m}", ENV['POP_TIMEOUT'] || 120)
      end
      pop
    end

    def process_uidl_list(conn)
      uidl_list = current_list - complete_list
      conn.mails.select {|_m|uidl_list.include?(_m.uidl)}
    end

    def match_rule?(mail)
      config.rule_with_conditions_select do |rule,mail_header,conditions|
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

class EncodeMail < Mail::Message
  def subject
    Kconv.toutf8(self[:Subject].value) if self[:Subject]
  end

  def utf_body
    if multipart?
      if text_part
        text_part.decoded.encode("UTF-8", charset)
      elsif html_part
        html_part.decoded.encode("UTF-8", charset)
      end
    else
      body.decoded.encode("UTF-8", charset)
    end
  end
end
