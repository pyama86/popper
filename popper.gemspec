# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'popper/version'

Gem::Specification.new do |spec|
  spec.name          = "popper"
  spec.version       = Popper::VERSION
  spec.authors       = ["pyama86"]
  spec.email         = ["pyama@pepabo.com"]

  spec.summary       = %q{email notification tool}
  spec.description   = %q{email notification tool}
  spec.description   = %q{TODO: Write a longer description or delete this line.}
  spec.homepage      = "http://ten-snapon.com"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'thor'
  spec.add_dependency 'slack-notifier'
  spec.add_dependency 'toml'
  spec.add_dependency 'mail'
  spec.add_dependency 'octokit'
  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end
