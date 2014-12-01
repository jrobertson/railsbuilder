Gem::Specification.new do |s|
  s.name = 'railsbuilder'
  s.version = '0.1.20'
  s.summary = 'Builds a Rails app from a configuration file.'
  s.authors = ['James Robertson']
  s.files = Dir['lib/**/*.rb']
  s.add_runtime_dependency('rails', '~> 4.1', '>=4.1.1')
  s.add_runtime_dependency('lineparser', '~> 0.1', '>=0.1.13')
  s.add_runtime_dependency('rdiscount', '~> 2.1', '>=2.1.7.1')
  s.add_runtime_dependency('rxfhelper', '~> 0.1', '>=0.1.12')
  s.add_runtime_dependency('activity-logger', '~> 0.1', '>=0.1.15')
  s.signing_key = '../privatekeys/railsbuilder.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@r0bertson.co.uk'
  s.homepage = 'https://github.com/jrobertson/railsbuilder'
  s.required_ruby_version = '>= 2.1.2'
end
