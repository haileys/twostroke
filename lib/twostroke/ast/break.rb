module Twostroke::AST
  class Break < Base
    def collapse
      self
    end
    
    def walk
      yield self
    end
  end
end