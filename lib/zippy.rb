require 'puppet'

module Zippy
  class Define
    def initialize(type,code)
      @type = type
      @code = code
    end

    def instantiate(title)
      Puppet.settings[:ignoreimport] = true
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
    Puppet.settings[:ignoreimport] = nil
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
