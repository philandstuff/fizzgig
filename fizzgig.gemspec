Gem::Specification.new do |s|
  s.name = 'fizzgig'
  s.version = '0.1.1'
  s.homepage = 'https://github.com/philandstuff/fizzgig'
  s.summary = 'Tools for writing fast unit tests for Puppet'
  s.description = 'Tools for writing fast unit tests for Puppet'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")

  s.add_dependency 'puppet'
  s.add_dependency 'lspace'
  s.add_development_dependency 'rspec'

  s.authors = ['Philip Potter']
  s.email = 'philip.g.potter@gmail.com'
end
