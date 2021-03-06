require 'puppet'
require 'fizzgig/function_stubs'
require 'lspace'

class Fizzgig
  def self.instantiate(type,title,params,options = {})
    LSpace.with(:function_stubs => options[:stubs]) do
      setup_fizzgig({modulepath: options[:modulepath],manifestdir: options[:manifestdir]})
      compiler = make_compiler(options[:facts])
      scope = compiler.newscope(nil)
      scope.source = Puppet::Resource::Type.new(:node,'localhost')
      # we need to force loading the type; normally this would be
      # handled by Puppet::Parser::AST::Resource calling
      # scope.resolve_type_and_titles
      scope.find_defined_resource_type(type)

      resource = Puppet::Parser::Resource.new(
                     type,
                     title,
                     :scope => scope,
                     :parameters => munge_params(params))
      resource.evaluate
      compiler.catalog
    end
  end

  def self.include(klass,options = {})
    LSpace.with(:function_stubs => options[:stubs]) do
      setup_fizzgig({modulepath: options[:modulepath],manifestdir: options[:manifestdir]})
      compiler = make_compiler(options[:facts])
      compile("include #{klass}",compiler)
      compiler.catalog
    end
  end

  def self.node(hostname,options = {})
    LSpace.with(:function_stubs => options[:stubs]) do
      setup_fizzgig({modulepath: options[:modulepath],manifestdir: options[:manifestdir]})
      Puppet[:code] = '' # we want puppet to import the Puppet[:manifest] file
      compiler = make_compiler(options[:facts], hostname)
      compiler.send :evaluate_ast_node
      compiler.catalog
    end
  end

  def self.munge_params(params)
    params.collect {|k,v| Puppet::Parser::Resource::Param.new(:name => k, :value => v)}
  end

  def self.make_compiler(facts,hostname='localhost')
    node = Puppet::Node.new(hostname)
    node.merge(facts) if facts
    compiler = Puppet::Parser::Compiler.new(node)
    compiler.send :set_node_parameters
    compiler.send :evaluate_main
    compiler
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

  def self.setup_fizzgig(settings={})
    Puppet[:code] = ' ' # hack to suppress puppet from looking at Puppet[:manifest]
    Puppet[:modulepath] = settings[:modulepath] || '/etc/puppet/modules'
    Puppet[:manifestdir] = settings[:manifestdir] || nil
    # stop template() fn from complaining about missing vardir config
    Puppet[:vardir] ||= ""
    # FIXME: decide if these are needed
    #c.add_setting :manifest, :default => nil
    #c.add_setting :template_dir, :default => nil
    #c.add_setting :config, :default => nil
  end

  # ===== OO interface ======
  # basically a glorified curried function to store the configuration

  def initialize(settings={})
    @modulepath  = settings[:modulepath]
    @manifestdir = settings[:manifestdir]
  end

  def instantiate(type,title,params,options={})
    Fizzgig.instantiate(type,title,params,options.merge({modulepath: @modulepath, manifestdir: @manifestdir}))
  end

  def include(classname,options={})
    Fizzgig.include(classname,options.merge({modulepath: @modulepath, manifestdir: @manifestdir}))
  end
  def node(hostname,options={})
    Fizzgig.node(hostname,options.merge({modulepath: @modulepath, manifestdir: @manifestdir}))
  end
end
