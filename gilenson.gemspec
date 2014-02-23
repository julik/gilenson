# coding: utf-8
$:.push File.expand_path("../lib", __FILE__)
require "gilenson/version"

Gem::Specification.new do |spec|
  spec.name          = "gilenson"
  spec.version       = Gilenson::VERSION
  spec.authors       = ["Julik Tarkhanov"]
  spec.email         = ["me@julik.nl"]
  spec.summary       = %q{Гиленсон — улучшайзер русской типографики}
  spec.homepage      = "http://github.com/julik/gilenson"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 1.9.3"
  spec.add_runtime_dependency "nokogiri", "~> 1.5"

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"

  # Gilenson на прямую не зависит от форматтеров,
  # он просто с ними интегрируется. Они нужны
  # только для тестиоования интеграции
  spec.add_development_dependency "rdiscount",  ">= 0"
  spec.add_development_dependency "maruku",     "~> 0.6"
  spec.add_development_dependency "RedCloth",   "~> 4.2"
  spec.add_development_dependency "bluecloth",  "~> 2.0"
end
