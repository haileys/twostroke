module Twostroke::AST
  class This < Base    
    def walk
      yield self
    end
  end
end