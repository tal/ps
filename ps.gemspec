# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ps/version"

Gem::Specification.new do |s|
  s.name        = "ps"
  s.version     = Ps::VERSION
  s.authors     = ["Tal Atlas"]
  s.email       = ["me@tal.by"]
  s.homepage    = ""
  s.summary     = %q{A ruby wrapper for the unix tool 'ps'}
  s.description = %q{A ruby utility for interacting with the unix tool 'ps'}

  s.rubyforge_project = "ps"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec"
end
