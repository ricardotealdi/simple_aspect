# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'simple_aspect/version'

Gem::Specification.new do |spec|
  spec.name          = "simple_aspect"
  spec.version       = SimpleAspect::VERSION
  spec.authors       = ["Ricardo Tealdi"]
  spec.email         = ["ricardo.tealdi@gmail.com"]

  spec.summary       = %q{Simple AOP implementation for Ruby}
  spec.description   = %q{Simple AOP implementation for Ruby}
  spec.homepage      = "https://github.com/ricardotealdi/simple_aspect"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rspec", '~> 3.4.0'
  spec.add_development_dependency "pry"
end
