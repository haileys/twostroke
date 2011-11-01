module Twostroke::Runtime
  class VM    
    attr_accessor :bytecode
    attr_reader :global_scope, :lib
    
    def initialize(bytecode)
      @bytecode = bytecode
      @global_scope = GlobalScope.new
      @lib = {}
    end
    
    def execute(section = :main, scope = nil)
      Frame.new(self, section).execute scope      
    end
    
    def throw_error(type, message)
      throw :exception, lib[type].(nil, global_scope.root_object, [Types::String.new(message)])
    end
  
  private
    def error!(msg)
      raise RuntimeError, msg
    end
  end
end