module Twostroke::AST
  class Number < Base
    attr_accessor :number
    
    def collapse
      self
    end
    
    def walk
      yield self
    end
  end
end