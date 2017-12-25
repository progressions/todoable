
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'todoable/version'

Gem::Specification.new do |spec|
  spec.name          = 'todoable'
  spec.version       = Todoable::VERSION
  spec.authors       = ['Isaac Priestley']
  spec.email         = ['progressions@gmail.com']

  spec.summary       = 'Simple app to track todo items'
  spec.description   = 'Track todo items'
  spec.homepage      = 'https://github.com/progressions/todoable'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'pry', '~> 0.11'
  spec.add_dependency 'activesupport'
  spec.add_dependency 'rest-client'
end
