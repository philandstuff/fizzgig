require 'rspec/autorun'
require 'fizzgig'

HERE = File.expand_path(File.dirname(__FILE__))

RSpec.configure do |c|
  c.modulepath  = "#{File.join(HERE, 'modules')}:#{File.join(HERE, 'extra_modules')}"

  c.include Fizzgig::CatalogMatchers
end
