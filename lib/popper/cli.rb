require 'popper'
require 'thor'

module Popper
  class CLI < Thor
    map %w[--version -v] => :__print_version
    desc "--version, -v", "print the version"
    def __print_version
      puts "Popper version:#{Popper::VERSION}"
    end
  end
end
