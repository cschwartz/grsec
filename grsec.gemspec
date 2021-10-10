# frozen_string_literal: true

require_relative "lib/grsec/identity"

Gem::Specification.new do |spec|
  spec.name = Grsec::Identity::NAME
  spec.version = Grsec::Identity::VERSION
  spec.platform = Gem::Platform::RUBY
  spec.authors = ["Christian Schwartz"]
  spec.email = ["christian.schwartz@gmail.com"]
  spec.homepage = "https://github.com//grsec"
  spec.summary = ""
  spec.license = "MIT"

  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/cschwartz/grsec/issues",
    "changelog_uri" => "https://github.com/cschwartz/grsec/blob/master/CHANGES.md",
    "documentation_uri" => "https://github.com/cschwartz/grsec",
    "source_code_uri" => "https://github.com/cschwartz/grsec"
  }

  spec.signing_key = Gem.default_key_path
  spec.cert_chain = [Gem.default_cert_path]

  spec.required_ruby_version = "~> 3.0"
  spec.add_dependency "runcom", "~> 7.0"
  spec.add_dependency "thor", "~> 0.20"

  spec.files = Dir["lib/**/*"]
  spec.extra_rdoc_files = Dir["README*", "LICENSE*"]
  spec.executables << "grsec"
  spec.require_paths = ["lib"]
end
