module Twostroke::AST
  class Continue < Base
    attr_accessor :label
    
    def collapse
      self
    end
    
    def walk
      yield self
    end
  end
end