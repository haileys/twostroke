module Twostroke::AST
  class DoWhile < Base
    attr_accessor :body, :condition
    
    def walk(&bk)
      if yield self
        condition.walk &bk
        body.walk &bk
      end
    end
  end
end