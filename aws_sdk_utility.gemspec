# frozen_string_literal: true

require_relative 'lib/aws_sdk_utility/version'

Gem::Specification.new do |spec|
  spec.name          = 'aws_sdk_utility'
  spec.version       = AwsSdkUtility::VERSION
  spec.authors       = ['sachinsaxena1996']
  spec.email         = ['dev@yourmechanic.com']

  spec.summary       = 'aws_sdk_utility provides utility methods for aws.'
  spec.description   = 'aws_sdk_utility provides utility methods for aws.'
  spec.homepage      = 'https://github.com/YourMechanic/aws_sdk_utility'
  spec.license       = 'MIT'
  # spec.required_ruby_version = Gem::Requirement.new(">= 2.4.0")

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/YourMechanic/postgres_utility'
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html

  spec.add_development_dependency 'aws-sdk', '1.11.1'
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.48.1'
end
