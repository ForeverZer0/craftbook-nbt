# frozen_string_literal: true

require_relative 'lib/craftbook/nbt/version'

#noinspection RubyResolve
Gem::Specification.new do |spec|
  spec.name          = 'craftbook-nbt'
  spec.version       = CraftBook::NBT::VERSION
  spec.authors       = ['ForeverZer0']
  spec.email         = ['efreed09@gmail.com']

  spec.summary       = 'A feature-rich and complete Ruby implementation of the Named Binary Tag (NBT) format and SNBT parser.'
  spec.description   = 'A feature-rich and complete Ruby implementation of the Named Binary Tag (NBT) format. While it is an integral part of the broader CraftBook API, it is an independent module with no dependencies, and can be used for any purpose where reading/writing/converting the NBT format is required.'
  spec.homepage      = 'https://github.com/ForeverZer0/craftbook-nbt'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 2.4.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/ForeverZer0/craftbook-nbt'
  spec.metadata['changelog_uri'] = 'https://github.com/ForeverZer0/craftbook-nbt/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency('rake',     '~> 13.0')
  spec.add_development_dependency('rexical',  '~> 1.0')

end
