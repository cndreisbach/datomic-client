# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "datomic/client"

Gem::Specification.new do |s|
  s.name        = "datomic-client"
  s.version     = Datomic::Client::VERSION
  s.homepage    = "http://github.com/cldwalker/datomic-client"
  s.authors     = "Gabriel Horner"
  s.email       = "gabriel.horner@gmail.com"
  s.homepage    = "http://github.com/cldwalker/datomic-client"
  s.summary     = %q{client for datomic's rest API}
  s.description = "This client provides a simple way to use datomic's REST API - http://docs.datomic.com/rest.html."

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rake', '~> 0.9.2.2'
  s.add_dependency 'rest-client'
end