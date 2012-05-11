module Twostroke::AST
  class ExpressionStatement < Base
    attr_accessor :expr
    
    def walk(&bk)
      if yield self
        expr.walk &bk
      end
    end
  end
end