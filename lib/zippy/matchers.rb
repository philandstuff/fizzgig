module Zippy
  module CatalogMatchers
    extend RSpec::Matchers::DSL

    class CatalogMatcher
      #    matcher :contain_file do |expected_title|
      def initialize(expected_type,expected_title)
        @expected_type = expected_type
        @expected_title = expected_title
        @referenced_type = referenced_type(expected_type)
      end

      def matches?(catalog)
        @catalog = catalog
        resource = catalog.resource(@referenced_type,@expected_title)
        if resource then
          (@expected_params || {}).all? do |name,expected_val|
            if expected_val.kind_of?(Regexp)
              resource[name] =~ expected_val
            else
              resource[name] == expected_val
            end
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
        possible_resource = @catalog.resource(@referenced_type,@expected_title)
        actual = possible_resource ? possible_resource.inspect : "the catalog"
        "expected #{actual} to contain #{@referenced_type}[#{@expected_title}]#{param_string}"
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

      private

      def referenced_type(type)
        type.split('__').map { |r| r.capitalize }.join('::')
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
