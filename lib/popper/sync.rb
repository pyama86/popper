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
      work_dir = if Popper.configure.global.respond_to?(:work_dir)
               Popper.configure.global.work_dir
             else
               "/var/tmp"
             end
      File.join(work_dir, "popper.lock")
    end
  end
end
