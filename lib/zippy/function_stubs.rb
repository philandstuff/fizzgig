
module Zippy::FunctionStubs
  def self.has_stub?(fname,args)
    spec = Thread.current[:spec]
    spec &&
      spec.respond_to?(:function_stubs) &&
      spec.function_stubs.has_key?(fname.to_sym) &&
      spec.function_stubs[fname.to_sym][args[0]]
  end

  def self.get_stub(fname,args)
    spec = Thread.current[:spec]
    spec.function_stubs[fname.to_sym][args[0]]
  end
end

class Puppet::Parser::AST
  class Function < AST::Branch
    alias_method :orig_evaluate, :evaluate

    def evaluate(scope)
      #FIXME: are there implications around potential
      #double-evaluation here?
      args = @arguments.safeevaluate(scope).map { |x| x == :undef ? '' : x }
      if Zippy::FunctionStubs.has_stub?(@name,args)
        Zippy::FunctionStubs.get_stub(@name,args)
      else
        orig_evaluate(scope)
      end
    end
  end
end
