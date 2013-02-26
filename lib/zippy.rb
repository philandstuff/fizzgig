require 'puppet'
require 'zippy/matchers'

module Zippy
  def self.instantiate(code)
    Puppet[:manifestdir] = RSpec.configuration.manifest_dir
    Puppet[:modulepath] = RSpec.configuration.module_path
    # stop template() fn from complaining about missing vardir config
    Puppet[:templatedir] = ""
    compiler = Puppet::Parser::Compiler.new(Puppet::Node.new('localhost'))
    parser = Puppet::Parser::Parser.new compiler.environment.name
    ast = parser.parse(code)
    resources = ast.code[0].evaluate(compiler.topscope)
    resources[0].evaluate
    compiler.catalog
  end
end

RSpec.configure do |c|
  c.add_setting :module_path, :default => '/etc/puppet/modules'
  c.add_setting :manifest_dir, :default => nil

  # FIXME: decide if these are needed
  #c.add_setting :manifest, :default => nil
  #c.add_setting :template_dir, :default => nil
  #c.add_setting :config, :default => nil
end
