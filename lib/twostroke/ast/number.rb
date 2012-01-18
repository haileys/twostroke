module Twostroke::AST
  class Number < Base
    attr_accessor :number
    
    def walk
      yield self
    end
  end
end