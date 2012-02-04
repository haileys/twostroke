module Twostroke::AST
  class UserOperator < Base
    attr_accessor :left, :right, :operator
    
    def walk(&bk)
      if yield self
        left.walk &bk
        right.walk &bk
      end
    end
  end
end