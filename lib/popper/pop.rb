require 'net/pop'
require 'mail'
module Popper
  class Pop
    def self.run
      begin
        Popper::Sync.synchronized do
          Popper.configure.accounts.each do |profile|
            uidls = pop(profile)
            last_uidl(profile.name, uidls)
          end
        end
      rescue Locked
        puts "There will be a running process"
      end
    end

    def self.pop(profile)
      uidls = []
      Popper.log.info "start popper #{profile.name}"

      connection(profile) do |pop|
        pop.mails.reject {|m| last_uidl(profile.name).include?(m.uidl) }.each do |m|
          mail = Mail.new(m.mail)
          if rule = match_rule?(profile, mail)
            Popper.log.info "match mail #{mail.subject}"
            Popper::Action::Git.run(profile.action_by_rule(rule), mail) if profile.action_by_rule(rule)
          end
          uidls << m.uidl
        end
        Popper.log.info "success popper #{profile.name}"
      end
      uidls
    end

    def self.connection(profile, &block)
      Net::POP3.start(
        profile.login.server,
        profile.login.port || 110,
        profile.login.user,
        profile.login.password
      ) do |pop|
        block.call(pop)
      end
      rescue => e
        Popper.log.warn e
    end

    def self.match_rule?(profile, mail)
      profile.rules.to_h.keys.find do |rule|
        # merge default rule
        rule_hash = Popper.configure.default.respond_to?(:condition) ? Popper.configure.default.condition.to_h : {}
        rule_hash.deep_merge(profile.condition_by_rule(rule).to_h).all? do |header,conditions|
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
      Popper.configure.accounts.each do |profile|
        puts "start prepop #{profile.name}"
        connection(profile) do |pop|
          uidls = pop.mails.map(&:uidl)
          last_uidl(
            profile.name,
            uidls
          )
          puts "success prepop #{profile.name} mail count:#{uidls.count}"
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
