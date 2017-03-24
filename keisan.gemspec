# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'keisan/version'

Gem::Specification.new do |spec|
  spec.name          = "keisan"
  spec.version       = Keisan::VERSION
  spec.authors       = ["Christopher Locke"]
  spec.email         = ["project.eutopia@gmail.com"]

  spec.summary       = %q{An equation parser and evaluator}
  spec.description   = %q{A library for parsing equations into an abstract syntax tree for evaluation}
  spec.homepage      = "https://github.com/project-eutopia/keisan"
  spec.licenses      = %w(MIT)

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.4.0'

  spec.add_dependency "activesupport", ">= 4.2.2"

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-stack_explorer"
end
