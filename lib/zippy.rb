require 'puppet'
require 'zippy/matchers'

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
    scope = Puppet::Parser::Scope.new(compiler)
    scope.source = Puppet::Resource::Type.new(:node,'localhost')
    scope.parent = compiler.topscope
    ast = parser.parse("include #{klass}")
    resources = ast.code[0].evaluate(scope)
    compiler.catalog
  end

end

module Puppet::Parser::Functions
  class << self
    alias_method :real_newfunction, :newfunction
    def newfunction(name, options = {}, &block)
      func = real_newfunction(name, options, &block)
      real_fname = "real_function_#{name}"
      orig_fname = "orig_function_#{name}"
      environment_module.send(:alias_method, orig_fname.to_sym, real_fname.to_sym)
      environment_module.send(:define_method, real_fname) do |args|
        spec = Thread.current[:spec]
        if spec && spec.respond_to?(:function_stubs) && spec.function_stubs.has_key?(name.to_sym)
          spec.function_stubs[name.to_sym][args[0]]
        else
          self.send(orig_fname, args)
        end
      end
      func
    end
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
