# -*- encoding: utf-8 -*-
# stub: rainbow 2.2.2 ruby lib
# stub: ext/mkrf_conf.rb

Gem::Specification.new do |s|
  s.name = "rainbow".freeze
  s.version = "2.2.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Marcin Kulik".freeze]
  s.date = "2017-04-21"
  s.description = "Colorize printed text on ANSI terminals".freeze
  s.email = ["m@ku1ik.com".freeze]
  s.extensions = ["ext/mkrf_conf.rb".freeze]
  s.files = ["ext/mkrf_conf.rb".freeze]
  s.homepage = "https://github.com/sickill/rainbow".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.2".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Colorize printed text on ANSI terminals".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<rake>.freeze, [">= 0"])
  s.add_development_dependency(%q<bundler>.freeze, ["~> 1.3"])
end
