module Twostroke::AST
  class Return < Base
    attr_accessor :expression
    
    def walk(&bk)
      if yield self
        expression.walk &bk if expression
      end
    end
  end
end