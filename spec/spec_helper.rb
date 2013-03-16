require 'rspec/autorun'
require 'zippy'

HERE = File.expand_path(File.dirname(__FILE__))

RSpec.configure do |c|
  c.modulepath  = File.join(HERE, 'modules')

  c.include Fizzgig::CatalogMatchers
end
