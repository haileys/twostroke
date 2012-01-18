module Twostroke::AST
  class MultiExpression < Base
    attr_accessor :left, :right
    
    def walk(&bk)
      if yield self
        left.walk &bk
        right.walk &bk
      end
    end
  end
end