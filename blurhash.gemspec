# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'blurhash/version'

Gem::Specification.new do |spec|
  spec.name          = 'blurhash'
  spec.version       = Blurhash::VERSION
  spec.authors       = ['Eugen Rochko']
  spec.email         = ['eugen@zeonfederated.com']

  spec.summary       = %q{Encode an image as a small string that can saved in the database and used to show a blurred preview before the real image loads}
  spec.homepage      = 'https://github.com/Gargron/blurhash'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.require_paths = ['lib']
  spec.extensions    = ['ext/blurhash/extconf.rb']

  spec.add_dependency 'ffi', '~> 1.10'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rake-compiler'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rmagick', '~> 3.1.0'
end
