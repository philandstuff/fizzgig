require 'puppet'

module Zippy
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

  module CatalogMatchers
    extend RSpec::Matchers::DSL

    class CatalogMatcher
      #    matcher :contain_file do |expected_title|
      def initialize(expected_type,expected_title)
        @expected_type = expected_type
        @expected_title = expected_title
        @referenced_type = expected_type.capitalize
      end

      def matches?(actual)
        resource = actual.find do |resource|
          resource.type == @referenced_type && resource.name == @expected_title
        end
        if resource then
          (@expected_params || {}).all? do |name,expected_val|
            resource[name] == expected_val
          end
        else
          false
        end
      end

      def failure_message_for_should
        param_string = ""
        if @expected_params
          param_string = " with parameters #{@expected_params.inspect}"
        end
        "expected the catalog to contain #{@referenced_type}[#{@expected_title}]#{param_string}"
      end

      def method_missing(method, *args, &block)
        if method.to_s =~ /^with_/
          param = method.to_s.gsub(/^with_/,'')
          @expected_params ||= {}
          @expected_params[param] = args[0]
          self
        else
          super
        end
      end
    end

    def method_missing(method, *args, &block)
      if method.to_s =~ /^contain_/
        resource_type = method.to_s.gsub(/^contain_/,'')
        CatalogMatcher.new(resource_type,args[0])
      else
        super
      end
    end
  end
end

RSpec.configure do |c|
  c.add_setting :module_path, :default => '/etc/puppet/modules'
  c.add_setting :manifest_dir, :default => nil

  c.include Zippy::CatalogMatchers
  # FIXME: decide if these are needed
  #c.add_setting :manifest, :default => nil
  #c.add_setting :template_dir, :default => nil
  #c.add_setting :config, :default => nil
end
