Gem::Specification.new do |s|
  s.name = 'zippy'
  s.version = '0.1.0'
  #s.homepage = 'https://github.com/philandstuff'
  s.summary = 'Tools for writing fast unit tests for Puppet'
  s.description = 'Tools for writing fast unit tests for Puppet'

  s.files = [
    'lib/zippy.rb',
  ]

  s.add_dependency 'puppet'
  s.add_dependency 'lspace'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'

  s.authors = ['Philip Potter']
  s.email = 'philip.g.potter@gmail.com'
end
