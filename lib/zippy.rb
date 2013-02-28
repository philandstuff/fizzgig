require 'puppet'
require 'zippy/matchers'
require 'zippy/function_stubs'

module Zippy
  def self.instantiate(code)
    Puppet[:manifestdir] = ''
    Puppet[:modulepath] = RSpec.configuration.modulepath
    # stop template() fn from complaining about missing vardir config
    Puppet[:templatedir] = ""
    compiler = Puppet::Parser::Compiler.new(Puppet::Node.new('localhost'))
    parser = Puppet::Parser::Parser.new compiler.environment.name
    ast = parser.parse(code)
    resources = ast.code[0].evaluate(compiler.topscope)
    resources[0].evaluate
    compiler.catalog
  end

  def self.include(klass)
    Puppet[:manifestdir] = ''
    Puppet[:modulepath] = RSpec.configuration.modulepath
    # stop template() fn from complaining about missing vardir config
    Puppet[:templatedir] = ""
    compiler = Puppet::Parser::Compiler.new(Puppet::Node.new('localhost'))
    parser = Puppet::Parser::Parser.new compiler.environment.name
    scope = nil
    if Puppet::PUPPETVERSION =~ /^3./
      scope = Puppet::Parser::Scope.new(compiler)
    else
      scope = Puppet::Parser::Scope.new(:compiler => compiler)
    end
    scope.source = Puppet::Resource::Type.new(:node,'localhost')
    scope.parent = compiler.topscope
    ast = parser.parse("include #{klass}")
    resources = ast.code[0].evaluate(scope)
    compiler.catalog
  end
end

RSpec.configure do |c|
  c.add_setting :modulepath, :default => '/etc/puppet/modules'

  c.before(:each) do
    Thread.current[:spec] = self
  end

  c.after(:each) do
    Thread.current[:spec] = nil
  end

  # FIXME: decide if these are needed
  #c.add_setting :manifestdir, :default => nil
  #c.add_setting :manifest, :default => nil
  #c.add_setting :template_dir, :default => nil
  #c.add_setting :config, :default => nil
end
