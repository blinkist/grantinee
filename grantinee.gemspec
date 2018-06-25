# frozen_string_literal: true

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "lib"))

require "grantinee/version"

Gem::Specification.new do |spec|
  spec.name          = "grantinee"
  spec.version       = Grantinee::VERSION
  spec.authors       = ["Paweł Komarnicki", "John Donner"]
  spec.email         = ["pawel@blinkist.com", "john@blinkist.com"]

  spec.summary       = '"Your permissions, freshly baked!" | A library to manage your database permissions for MySQL and Postgres'
  spec.description   = "A Ruby library to manage your database permissions for MySQL and PostgreSQL. Supports per-table, and per-column permissions for granular access and security."
  spec.homepage      = "https://github.com/blinkist/grantinee"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.dirname(__FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "method_source"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop"
end
