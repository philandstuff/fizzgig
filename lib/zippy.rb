require 'puppet'
require 'zippy/matchers'
require 'zippy/function_stubs'
require 'lspace'

module Zippy
  def self.instantiate(code,options = {})
    LSpace.with(:function_stubs => options[:stubs]) do
      setup_puppet
      compiler = Puppet::Parser::Compiler.new(Puppet::Node.new('localhost'))
      resources = compile(code,compiler)
      resources[0].evaluate
      compiler.catalog
    end
  end

  def self.include(klass,options = {})
    LSpace.with(:function_stubs => options[:stubs]) do
      setup_puppet
      compiler = Puppet::Parser::Compiler.new(Puppet::Node.new('localhost'))
      compile("include #{klass}",compiler)
      compiler.catalog
    end
  end

  def self.compile(code,compiler)
    resources_for(ast_for(code,compiler),compiler)
  end

  def self.resources_for(ast,compiler)
    scope = compiler.newscope(nil)
    scope.source = Puppet::Resource::Type.new(:node,'localhost')
    ast.code[0].evaluate(scope)
  end

  def self.ast_for(code,compiler)
    parser = Puppet::Parser::Parser.new compiler.environment.name
    parser.parse(code)
  end

  def self.setup_puppet
    Puppet[:manifestdir] = ''
    Puppet[:modulepath] = RSpec.configuration.modulepath
    # stop template() fn from complaining about missing vardir config
    Puppet[:templatedir] = ""
  end
end

RSpec.configure do |c|
  c.add_setting :modulepath, :default => '/etc/puppet/modules'

  # FIXME: decide if these are needed
  #c.add_setting :manifestdir, :default => nil
  #c.add_setting :manifest, :default => nil
  #c.add_setting :template_dir, :default => nil
  #c.add_setting :config, :default => nil
end
