module Twostroke::AST
  class True < Base    
    def collapse
      self
    end
    
    def walk(&bk)
      yield self
    end
  end
end