require 'net/pop'
require 'mail'
require 'kconv'

module Popper
  class MailAccount
    def initialize(config)
      @config = config
    end

    def run
      session_start do |conn|
        @current_uidl_list = conn.mails.map(&:uidl)
        @complete_uidl_list = @current_uidl_list unless @complete_uidl_list
        pop(conn)
      end
      rescue => e
        Popper.log.warn e
    end

    def pop(conn)
      done_uidls = []
      error_uidls = []

      Popper.log.info "start popper #{@config.name}"

      process_uidl_list(conn).each do |m|
        begin
          mail = EncodeMail.new(m.mail)
          Popper.log.info "check mail:#{mail.date.to_s} #{mail.subject}"

          if rule = match_rule?(mail)
            Popper.log.info "do action:#{mail.subject}"
            Popper::Action::Git.run(@config.action_by_rule(rule), mail) if @config.action_by_rule(rule)
          end
          done_uidls << m.uidl

        rescue Net::POPError => e
          @complete_uidl_list += done_uidls
          Popper.log.warn "pop err write uidl"
          return
        rescue => e
          error_uidls << m.uidl
          Popper.log.warn e
        end
      end

      @complete_uidl_list = @current_uidl_list - error_uidls
      Popper.log.info "success popper #{@config.name}"
    end

    def session_start(&block)
      pop = Net::POP3.new(@config.login.server, @config.login.port || 110)
      %w(
        open_timeout
        read_timeout
      ).each {|m| pop.instance_variable_set("@#{m}", ENV['POP_TIMEOUT'] || 120) }

      pop.start(
        @config.login.user,
        @config.login.password
      ) do |pop|
        Popper.log.info "connect server #{@config.name}"
        block.call(pop)
        Popper.log.info "disconnect server #{@config.name}"
      end
    end

    def process_uidl_list(conn)
      uidl_list = @current_uidl_list - @complete_uidl_list
      conn.mails.select {|_m|uidl_list.include?(_m.uidl)}
    end

    def match_rule?(mail)
      @config.rules.to_h.keys.find do |rule|
        @config.condition_by_rule(rule).to_h.all? do |mail_header,conditions|
          conditions.all? do |condition|
            mail.respond_to?(mail_header) && mail.send(mail_header).to_s.match(/#{condition}/)
          end
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

  def body
    if multipart?
      text_part.decoded.encode("UTF-8", charset) if text_part
      html_part.decoded.encode("UTF-8", charset) if html_part
    else
      super.decoded.encode("UTF-8", charset)
    end
  end
end
