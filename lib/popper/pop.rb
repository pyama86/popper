require 'net/pop'
require 'mail'
module Popper
  class Pop
    def self.run
      Popper.configure.account.each do |profile|
        uidls = []
        begin
          Popper.log.info "start popper #{profile.name}"
          Net::POP3.start(profile.login.server, profile.login.port || 110, profile.login.user, profile.login.password) do |pop|
            pop.mails.each do |m|
              uidls << m.uidl
              next if last_uidl(profile.name).include?(m.uidl)
              mail = Mail.new(m.mail)
              if rule = match_rule?(profile, mail)
                Popper.log.info "match mail #{mail.subject}"
                Popper::Action::Git.run(profile.rules.send(rule).action, mail)
              end
            end
          end
        rescue => e
          Popper.log.warn e
        end

        last_uidl(profile.name, uidls)
        Popper.log.info "success popper #{profile.name}"
      end
    end

    def self.prepop
      Popper.configure.account.each do |profile|
        uidls = []
        begin
          Popper.log.info "start prepop #{profile.name}"
          Net::POP3.start(profile.login.server, profile.login.port || 110, profile.login.user, profile.login.password) do |pop|
            puts "start prepop #{profile.name}"
            pop.mails.each do |m|
              uidls << m.uidl
            end
          end
        rescue => e
          puts e
        end

        last_uidl(profile.name, uidls)
        puts "success prepop #{profile.name}"
      end
    end

    def self.match_rule?(profile, mail)
      profile.rules.to_h.keys.find do |rule|
        profile.rules.send(rule).condition.to_h.all? do |k,v|
          mail.send(k).to_s.match(/#{v}/)
        end
      end
    end

    def self.last_uidl(account, uidl=nil)
      path = File.join(Dir.home, "popper", ".#{account}.uidl")
      @_uidl ||= {}

      File.write(File.join(path), uidl.join("\n")) if uidl

      @_uidl[account] ||= File.read(path).split(/\r?\n/) if File.exist?(path)
      @_uidl[account]
    end
  end
end
