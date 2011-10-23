module Twostroke::AST
  class Continue < Base
    def collapse
      self
    end
    
    def walk
      yield self
    end
  end
end