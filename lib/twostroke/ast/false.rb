module Twostroke::AST
  class False < Base    
    def collapse
      self
    end
    
    def walk(&bk)
      yield self
    end
  end
end