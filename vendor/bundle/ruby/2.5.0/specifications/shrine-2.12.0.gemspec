# -*- encoding: utf-8 -*-
# stub: shrine 2.12.0 ruby lib

Gem::Specification.new do |s|
  s.name = "shrine".freeze
  s.version = "2.12.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Janko Marohni\u0107".freeze]
  s.date = "2018-08-21"
  s.description = "Shrine is a toolkit for file attachments in Ruby applications. It supports\nuploading, downloading, processing and deleting IO objects, backed by various\nstorage engines. It uses efficient streaming for low memory usage.\n\nShrine comes with a high-level interface for attaching uploaded files to\ndatabase records, saving their location and metadata to a database column, and\ntying them to record's lifecycle. It natively supports background jobs and\ndirect uploads for fully asynchronous user experience.\n".freeze
  s.email = ["janko.marohnic@gmail.com".freeze]
  s.homepage = "https://github.com/shrinerb/shrine".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.1".freeze)
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Toolkit for file attachments in Ruby applications".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<down>.freeze, ["~> 4.1"])
      s.add_development_dependency(%q<rake>.freeze, [">= 11.1"])
      s.add_development_dependency(%q<minitest>.freeze, ["~> 5.8"])
      s.add_development_dependency(%q<minitest-hooks>.freeze, ["~> 1.3"])
      s.add_development_dependency(%q<mocha>.freeze, ["~> 1.4"])
      s.add_development_dependency(%q<rack-test_app>.freeze, [">= 0"])
      s.add_development_dependency(%q<shrine-memory>.freeze, [">= 0.2.2"])
      s.add_development_dependency(%q<roda>.freeze, [">= 0"])
      s.add_development_dependency(%q<rack>.freeze, [">= 0"])
      s.add_development_dependency(%q<mimemagic>.freeze, [">= 0.3.2"])
      s.add_development_dependency(%q<marcel>.freeze, [">= 0"])
      s.add_development_dependency(%q<mime-types>.freeze, [">= 0"])
      s.add_development_dependency(%q<mini_mime>.freeze, ["~> 1.0"])
      s.add_development_dependency(%q<fastimage>.freeze, [">= 0"])
      s.add_development_dependency(%q<mini_magick>.freeze, ["~> 4.0"])
      s.add_development_dependency(%q<ruby-vips>.freeze, ["~> 2.0"])
      s.add_development_dependency(%q<aws-sdk-s3>.freeze, ["~> 1.2"])
      s.add_development_dependency(%q<aws-sdk-core>.freeze, ["~> 3.23"])
      s.add_development_dependency(%q<ruby-filemagic>.freeze, ["~> 0.7"])
      s.add_development_dependency(%q<sequel>.freeze, [">= 0"])
      s.add_development_dependency(%q<activerecord>.freeze, ["~> 5.0"])
      s.add_development_dependency(%q<sqlite3>.freeze, [">= 0"])
    else
      s.add_dependency(%q<down>.freeze, ["~> 4.1"])
      s.add_dependency(%q<rake>.freeze, [">= 11.1"])
      s.add_dependency(%q<minitest>.freeze, ["~> 5.8"])
      s.add_dependency(%q<minitest-hooks>.freeze, ["~> 1.3"])
      s.add_dependency(%q<mocha>.freeze, ["~> 1.4"])
      s.add_dependency(%q<rack-test_app>.freeze, [">= 0"])
      s.add_dependency(%q<shrine-memory>.freeze, [">= 0.2.2"])
      s.add_dependency(%q<roda>.freeze, [">= 0"])
      s.add_dependency(%q<rack>.freeze, [">= 0"])
      s.add_dependency(%q<mimemagic>.freeze, [">= 0.3.2"])
      s.add_dependency(%q<marcel>.freeze, [">= 0"])
      s.add_dependency(%q<mime-types>.freeze, [">= 0"])
      s.add_dependency(%q<mini_mime>.freeze, ["~> 1.0"])
      s.add_dependency(%q<fastimage>.freeze, [">= 0"])
      s.add_dependency(%q<mini_magick>.freeze, ["~> 4.0"])
      s.add_dependency(%q<ruby-vips>.freeze, ["~> 2.0"])
      s.add_dependency(%q<aws-sdk-s3>.freeze, ["~> 1.2"])
      s.add_dependency(%q<aws-sdk-core>.freeze, ["~> 3.23"])
      s.add_dependency(%q<ruby-filemagic>.freeze, ["~> 0.7"])
      s.add_dependency(%q<sequel>.freeze, [">= 0"])
      s.add_dependency(%q<activerecord>.freeze, ["~> 5.0"])
      s.add_dependency(%q<sqlite3>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<down>.freeze, ["~> 4.1"])
    s.add_dependency(%q<rake>.freeze, [">= 11.1"])
    s.add_dependency(%q<minitest>.freeze, ["~> 5.8"])
    s.add_dependency(%q<minitest-hooks>.freeze, ["~> 1.3"])
    s.add_dependency(%q<mocha>.freeze, ["~> 1.4"])
    s.add_dependency(%q<rack-test_app>.freeze, [">= 0"])
    s.add_dependency(%q<shrine-memory>.freeze, [">= 0.2.2"])
    s.add_dependency(%q<roda>.freeze, [">= 0"])
    s.add_dependency(%q<rack>.freeze, [">= 0"])
    s.add_dependency(%q<mimemagic>.freeze, [">= 0.3.2"])
    s.add_dependency(%q<marcel>.freeze, [">= 0"])
    s.add_dependency(%q<mime-types>.freeze, [">= 0"])
    s.add_dependency(%q<mini_mime>.freeze, ["~> 1.0"])
    s.add_dependency(%q<fastimage>.freeze, [">= 0"])
    s.add_dependency(%q<mini_magick>.freeze, ["~> 4.0"])
    s.add_dependency(%q<ruby-vips>.freeze, ["~> 2.0"])
    s.add_dependency(%q<aws-sdk-s3>.freeze, ["~> 1.2"])
    s.add_dependency(%q<aws-sdk-core>.freeze, ["~> 3.23"])
    s.add_dependency(%q<ruby-filemagic>.freeze, ["~> 0.7"])
    s.add_dependency(%q<sequel>.freeze, [">= 0"])
    s.add_dependency(%q<activerecord>.freeze, ["~> 5.0"])
    s.add_dependency(%q<sqlite3>.freeze, [">= 0"])
  end
end
