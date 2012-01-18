module Twostroke::AST
  class If < Base
    attr_accessor :condition, :then, :else
    
    def walk(&bk)
      if yield self
        condition.walk &bk
        @then.walk &bk
        @else.walk &bk if @else
      end
    end
  end
end