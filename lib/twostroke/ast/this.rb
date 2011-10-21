module Twostroke::AST
  class This < Base
    def collapse; self; end
    
    def walk
      yield self
    end
  end
end