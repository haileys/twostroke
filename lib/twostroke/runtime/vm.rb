module Twostroke::Runtime
  class VM    
    attr_accessor :bytecode
    attr_reader :global_scope
    
    def initialize(bytecode)
      @bytecode = bytecode
      @global_scope = GlobalScope.new
    end
    
    def execute(section = :main, scope = nil)
      Frame.new(self, section).execute scope      
    end
  
  private
    def error!(msg)
      raise RuntimeError, msg
    end
  end
end