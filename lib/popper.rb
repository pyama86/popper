require 'pp'
require 'popper/version'
require 'popper/cli'
require 'popper/mail_account'
require 'popper/config'
require 'popper/action'
require 'popper/init'

module Popper
  def self.init_logger(options, stdout = nil)
    log_path = options[:log] || '/var/log/popper.log'
    log_path = STDOUT if ENV['POPPER_TEST'] || stdout
    @_logger = Logger.new(log_path)
  rescue StandardError => e
    puts e
  end

  def self.log
    @_logger
  end
end

# ref: https://github.com/ruby/net-pop/issues/27
module Net
  class POP3Command
    def list
      critical do
        getok 'LIST'
        list = []
        @socket.each_list_item do |line|
          if line.split(' ').size != 2
            num, uid = line.split(' ')[2..3]
            list.push [num.to_i, uid.to_i]
          end
          m = /\A(\d+)[ \t]+(\d+)/.match(line) or
            raise POPBadResponse, "bad response: #{line}"
          list.push [m[1].to_i, m[2].to_i]
        end
        return list
      end
    end

    def uidl(num = nil)
      if num
        res = check_response(critical { get_response('UIDL %d', num) })
        res.split(/ /)[1]
      else
        critical do
          getok('UIDL')
          table = {}
          @socket.each_list_item do |line|
            if line.split(' ').size == 4
              num, uid = line.split(' ')[2..3]
              table[num.to_i] = uid
            end
            num, uid = line.split(' ')
            table[num.to_i] = uid
          end
          return table
        end
      end
    end
  end
end
