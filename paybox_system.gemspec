# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'paybox/system/version'

Gem::Specification.new do |spec|
  spec.name          = 'paybox_system'
  spec.version       = Paybox::System::VERSION
  spec.authors       = ['Nicolas Blanco']
  spec.email         = ['slainer68@gmail.com']

  spec.summary       = 'Paybox System e-commerce gateway Ruby implementation'
  spec.description   = 'Paybox System e-commerce gateway Ruby implementation'
  spec.homepage      = 'https://github.com/codeur/paybox_system'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://gems.codeur.com'

    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = 'https://github.com/codeur/paybox_system'
    spec.metadata['changelog_uri'] = 'https://github.com/codeur/paybox_system/releases'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.17'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rack', '>= 0'
  spec.add_development_dependency 'rake', '>= 10'
  spec.add_development_dependency 'rspec', '> 2.8.0'
  # spec.add_dependency(%q<rack>, [">= 0"])
  # spec.add_dependency(%q<rspec>, ["~> 2.8.0"])
  # spec.add_dependency(%q<rdoc>, ["~> 3.12"])
  # spec.add_dependency(%q<bundler>, ["~> 1.0"])
  # spec.add_dependency(%q<simplecov>, [">= 0"])
end
