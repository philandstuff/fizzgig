require 'rspec/autorun'
require 'zippy'

HERE = File.expand_path(File.dirname(__FILE__))

RSpec.configure do |c|
  c.module_path  = File.join(HERE, 'modules')
  c.manifest_dir = File.join(HERE, 'manifests')
end
