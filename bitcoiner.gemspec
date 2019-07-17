# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bitcoiner/version'

Gem::Specification.new do |spec|
  spec.name          = 'bitcoiner'
  spec.version       = Bitcoiner::VERSION
  spec.authors       = ['Bryce Kerley', 'Nihad Abbasov']
  spec.email         = ['nihad@42na.in']

  spec.summary       = 'Control the bitcoin nework client over JSON-RPC.'
  spec.description   = 'Automate your Bitcoin transactions with this Ruby interface to the bitcoind JSON-RPC API.'
  spec.homepage      = 'https://github.com/NARKOZ/bitcoiner'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.require_paths = ['lib']

  spec.add_dependency 'addressable'
  spec.add_dependency 'typhoeus', '~> 1.3.0'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'mocha', '~> 1.1.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'shoulda-context', '~> 1.2.2'
end
