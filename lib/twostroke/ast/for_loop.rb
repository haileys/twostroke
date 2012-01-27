module Twostroke::AST
  class ForLoop < Base
    attr_accessor :initializer, :condition, :increment, :body
    
    def walk(&bk)
      if yield self
        initializer.walk(&bk) if initializer
        condition.walk(&bk) if condition
        increment.walk(&bk) if increment
        body.walk &bk if body
      end
    end
  end
end