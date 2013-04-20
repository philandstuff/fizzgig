class Fizzgig
  module FunctionStubs
    def self.has_stub?(fname,args)
      stubs = LSpace[:function_stubs] || {}
      stubs.has_key?(fname.to_sym) &&
        stubs[fname.to_sym].has_key?(args)
    end

    def self.get_stub(fname,args)
      LSpace[:function_stubs][fname.to_sym][args]
    end
  end

  class Puppet::Parser::AST
    class Function < AST::Branch
      alias_method :orig_evaluate, :evaluate

      def evaluate(scope)
        #FIXME: are there implications around potential
        #double-evaluation here?
        args = @arguments.safeevaluate(scope).map { |x| x == :undef ? '' : x }
        if Fizzgig::FunctionStubs.has_stub?(@name,args)
          Fizzgig::FunctionStubs.get_stub(@name,args)
        else
          orig_evaluate(scope)
        end
      end
    end
  end
end
