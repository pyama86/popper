module Popper::Protocol
  class Pop
    attr_accessor :config, :connection, :current

    def initialize(config)
      self.config = config
    end

    def session_start(&block)
      pop = Net::POP3.new(config.login.server, config.login.port || 110)
      %w(
        open_timeout
        read_timeout
      ).each {|m| pop.instance_variable_set("@#{m}", ENV['POP_TIMEOUT'] || 120) }

      pop.start(
        config.login.user,
        config.login.password
      ) do |pop|
        self.connection = pop
        Popper.log.info "connect server #{config.name}"
        block.call
        Popper.log.info "disconnect server #{config.name}"
      end
    rescue Net::POPError => e
      raise Popper::ConnectonError
    end

    def current_list
      @_current ||= connection.mails.map(&:uidl)
    rescue Net::POPError => e
      raise Popper::ConnectonError
    end

    def process_list(complete_list)
      target = current_list - complete_list
      connection.mails.select {|_m|target.include?(_m.uidl)}
    rescue Net::POPError => e
      raise Popper::ConnectonError
    end

    def get_mail(m)
      self.current = m
      PopMail.new(m.mail)
    rescue Net::POPError => e
      raise Popper::ConnectonError
    end

    def current_id
      current.uidl
    end

  end
end

class PopMail < Mail::Message
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
