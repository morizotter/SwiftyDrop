# -*- encoding: utf-8 -*-
# stub: cocoapods-core 1.5.3 ruby lib

Gem::Specification.new do |s|
  s.name = "cocoapods-core".freeze
  s.version = "1.5.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Eloy Duran".freeze, "Fabio Pelosin".freeze]
  s.date = "2018-05-24"
  s.description = "The CocoaPods-Core gem provides support to work with the models of CocoaPods.\n\n It is intended to be used in place of the CocoaPods when the the installation of the dependencies is not needed.".freeze
  s.email = ["eloy.de.enige@gmail.com".freeze, "fabiopelosin@gmail.com".freeze]
  s.homepage = "https://github.com/CocoaPods/CocoaPods".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.0.0".freeze)
  s.rubygems_version = "2.6.8".freeze
  s.summary = "The models of CocoaPods".freeze

  s.installed_by_version = "2.6.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>.freeze, ["< 6", ">= 4.0.2"])
      s.add_runtime_dependency(%q<nap>.freeze, ["~> 1.0"])
      s.add_runtime_dependency(%q<fuzzy_match>.freeze, ["~> 2.0.4"])
      s.add_development_dependency(%q<bacon>.freeze, ["~> 1.1"])
    else
      s.add_dependency(%q<activesupport>.freeze, ["< 6", ">= 4.0.2"])
      s.add_dependency(%q<nap>.freeze, ["~> 1.0"])
      s.add_dependency(%q<fuzzy_match>.freeze, ["~> 2.0.4"])
      s.add_dependency(%q<bacon>.freeze, ["~> 1.1"])
    end
  else
    s.add_dependency(%q<activesupport>.freeze, ["< 6", ">= 4.0.2"])
    s.add_dependency(%q<nap>.freeze, ["~> 1.0"])
    s.add_dependency(%q<fuzzy_match>.freeze, ["~> 2.0.4"])
    s.add_dependency(%q<bacon>.freeze, ["~> 1.1"])
  end
end
