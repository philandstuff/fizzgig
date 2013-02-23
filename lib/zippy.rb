require 'puppet'

module Zippy
  class Define
    def initialize(type,code)
      @type = type
      @code = code
    end

    def instantiate(title)
      Puppet[:manifestdir] = RSpec.configuration.manifest_dir
      Puppet[:modulepath] = RSpec.configuration.module_path
      compiler = Puppet::Parser::Compiler.new(Puppet::Node.new('localhost'))
      parser = Puppet::Parser::Parser.new compiler.environment.name
      #FIXME what should the module name be? probably not jimmy
      compiler.known_resource_types.import_ast(parser.parse(@code),'jimmy')
      ast = parser.parse "foo{'#{title}':}"
      resources = ast.code[0].evaluate(compiler.topscope)
      resources[0].evaluate
      compiler.catalog.resources
    end
  end

  def self.instantiate(code)
    Puppet[:manifestdir] = RSpec.configuration.manifest_dir
    Puppet[:modulepath] = RSpec.configuration.module_path
    compiler = Puppet::Parser::Compiler.new(Puppet::Node.new('localhost'))
    parser = Puppet::Parser::Parser.new compiler.environment.name
    ast = parser.parse(code)
    resources = ast.code[0].evaluate(compiler.topscope)
    resources[0].evaluate
    compiler.catalog.resources
  end
end

RSpec::Matchers.define :contain_file do |title|
  match do |actual|
    actual.find do |resource|
      resource.type == 'File' && resource.name == title
    end
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
