module Popper
  class Locked < StandardError; end
  class Sync
    def self.synchronized
      File.open(lockfile, 'w') do |_lockfile|
        if _lockfile.flock(File::LOCK_EX|File::LOCK_NB)
          yield
        else
          raise Locked
        end
      end
    end

    def self.lockfile
      File.join(Dir.home, "popper", "popper.lock")
    end
  end
end
