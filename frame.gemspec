# frozen_string_literal: true

require_relative "lib/frame/version"

Gem::Specification.new do |spec|
  spec.name = "frame"
  spec.version = Frame::VERSION
  spec.authors = ["Sean Winner"]
  spec.email = ["srwinner16@gmail.com"]

  spec.summary = "Ruby bindings for the Frame Payments API"
  spec.description = "A Ruby library for Frame Payments API that provides a convenient interface for making requests and handling responses."
  spec.homepage = "https://github.com/seanwinner/frame"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/seanwinner/frame"
  spec.metadata["changelog_uri"] = "https://github.com/seanwinner/frame/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday", "~> 2.0"

  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "webmock", "~> 3.14"
end
