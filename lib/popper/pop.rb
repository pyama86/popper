require 'net/pop'
require 'mail'
require 'kconv'
module Popper
  class Pop
    def self.run
      begin
        Popper::Sync.synchronized do
          Popper.configure.accounts.each do |account|
            begin
              pop(account)
            rescue => e
              Popper.log warn e
            end
          end
        end
      rescue Locked
        puts "There will be a running process"
      end
    end

    def self.pop(account)
      current_uidls = []
      error_uidls = []
      Popper.log.info "start popper #{account.name}"
      connection(account) do |pop|
        pop.mails.reject {|m| current_uidls << m.uidl; last_uidl(account.name).include?(m.uidl) }.each do |m|
          begin
            mail = EncodeMail.new(m.mail)
            Popper.log.info "check mail:#{mail.date.to_s} #{mail.subject}"
            if rule = matching?(account, mail)
              Popper.log.info "do action:#{mail.subject}"
              Popper::Action::Git.run(account.action_by_rule(rule), mail) if account.action_by_rule(rule)
            end
          rescue => e
            error_uidls << m.uidl
            Popper.log.warn e
          end
        end
        # write cache
        last_uidl(account.name, current_uidls - error_uidls)
        Popper.log.info "success popper #{account.name}"
      end
    end

    def self.connection(account, &block)
      pop = Net::POP3.new(account.login.server, account.login.port || 110)
      pop.open_timeout = ENV['POP_TIMEOUT'] || 120
      pop.read_timeout = ENV['POP_TIMEOUT'] || 120
      pop.start(
        account.login.user,
        account.login.password
      ) do |pop|
        block.call(pop)
      end
    end

    def self.matching?(account, mail)
      account.rules.to_h.keys.find do |rule|
        account.condition_by_rule(rule).to_h.all? do |header,conditions|
          conditions.all? do |condition|
            mail.respond_to?(header) && mail.send(header).to_s.match(/#{condition}/)
          end
        end
      end
    end

    def self.last_uidl(account, uidl=nil)
      path = File.join(Dir.home, "popper", ".#{account}.uidl")
      @_uidl ||= {}

      File.write(File.join(path), uidl.join("\n")) if uidl

      @_uidl[account] ||= File.exist?(path) ? File.read(path).split(/\r?\n/) : []
      @_uidl[account]
    end

    def self.prepop
      Popper.configure.accounts.each do |account|
        Popper.log.info "start prepop #{account.name}"
        connection(account) do |pop|
          begin
            uidls = pop.mails.map(&:uidl)
            last_uidl(
              account.name,
              uidls
            )
            Popper.log.info "success prepop #{account.name} mail count:#{uidls.count}"
          rescue => e
            Popper.log.warn  e
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
    super.decoded.encode("UTF-8", self.charset)
  end
end
