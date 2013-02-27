
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

module Puppet::Parser::Functions
  class << self
    alias_method :real_newfunction, :newfunction
    def newfunction(name, options = {}, &block)
      func = real_newfunction(name, options, &block)
      real_fname = "real_function_#{name}"
      orig_fname = "orig_function_#{name}"
      environment_module.send(:alias_method, orig_fname.to_sym, real_fname.to_sym)
      environment_module.send(:define_method, real_fname) do |args|
        if Zippy::FunctionStubs.has_stub?(name,args)
          Zippy::FunctionStubs.get_stub(name,args)
        else
          self.send(orig_fname, args)
        end
      end
      func
    end
  end
end
