module Popper
  class Init
    def self.run(options)
      dirname = options[:config] || File.join(Dir.home, "popper")
      unless FileTest.exist?(dirname)
        FileUtils.mkdir_p(dirname)
        open("#{dirname}/popper.conf","w") do |e|
          e.puts sample_config
        end if FileTest.exist?(dirname)
        puts "create directry ~/popper"
      end
    end

    def self.sample_config
      File.read('lib/popper/sample/config.txt')
    end
  end
end
