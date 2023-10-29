# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'icalendar/recurrence/version'

Gem::Specification.new do |spec|
  spec.name          = "icalendar-recurrence"
  spec.version       = Icalendar::Recurrence::VERSION
  spec.authors       = ["Jordan Raine"]
  spec.email         = ["jnraine@gmail.com"]
  spec.summary       = %q{Provides recurrence to icalendar gem.}
  spec.homepage      = "https://github.com/icalendar/icalendar-recurrence"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'icalendar', '~> 2.0'
  spec.add_runtime_dependency 'ice_cube', '~> 0.16'

  spec.add_development_dependency 'activesupport', '~> 7.1'
  spec.add_development_dependency 'awesome_print'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '>= 12.3.3'
  spec.add_development_dependency 'rspec', '~> 3.12'
  spec.add_development_dependency 'timecop', '~> 0.9'
  spec.add_development_dependency 'tzinfo', '~> 2.0'
end
