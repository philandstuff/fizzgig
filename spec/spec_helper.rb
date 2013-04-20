require 'rspec/autorun'
require 'fizzgig'

HERE = File.expand_path(File.dirname(__FILE__))
MODULEPATH  = "#{File.join(HERE, 'modules')}:#{File.join(HERE, 'extra_modules')}"
MANIFESTDIR = File.join(HERE,'manifests')

RSpec.configure do |c|
  c.include Fizzgig::CatalogMatchers
end
