require 'net/pop'
require 'mail'
module Popper
  class Pop
    def self.run
      Popper.configure.account.each do |profile|
        uidls = []
        Net::POP3.start(profile.login.server, profile.login.port || 110, profile.login.user, profile.login.password) do |pop|
          puts "start popper #{profile.name}"
          pop.mails.each do |m|
            uidls << m.uidl
            next if last_uidl(profile.name).include?(m.uidl)
            mail = Mail.new(m.mail)
            if rule = match_rule?(profile, mail)
              execute_action(profile, mail, rule)
            end
          end
        end
        last_uidl(account, uidls)
        puts "success popper #{profile.name}"
      end
    end

    def self.execute_action(profile, mail, rule)
      profile.rules.send(rule).action.to_h.keys.each do |action_name|
        const_get("Popper::#{action_name.to_s.capitalize!}").run(profile.rules.send(rule).action.send(action_name) , mail)
      end
    end

    def self.match_rule?(profile, mail)
      profile.rules.to_h.keys.find do |rule|
        profile.rules.send(rule).condition.to_h.any? do |k,v|
          mail.send(k).match(/#{v}/)
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
