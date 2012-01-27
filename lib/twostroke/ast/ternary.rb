module Twostroke::AST
  class Ternary < Base
    attr_accessor :condition, :if_true, :if_false
    
    def walk(&bk)
      if yield self
        condition.walk &bk
        if_true.walk &bk
        if_false.walk &bk
      end
    end
  end
end