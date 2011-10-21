module Twostroke::AST
  class Null < Base
    def collapse
      self
    end
    
    def walk
      yield self
    end
  end
end