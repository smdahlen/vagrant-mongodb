# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vagrant-mongodb/version'

Gem::Specification.new do |gem|
  gem.name          = 'vagrant-mongodb'
  gem.version       = VagrantPlugins::MongoDb::VERSION
  gem.authors       = ['Shawn Dahlen']
  gem.email         = ['shawn@dahlen.me']
  gem.description   = %q{A Vagrant plugin that manages a MongoDb replicaset}
  gem.homepage      = 'https://github.com/smdahlen/vagrant-mongodb'
  gem.summary       = gem.description

  gem.files         = `git ls-files`.split($/)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']
end
