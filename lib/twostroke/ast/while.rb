module Twostroke::AST
  class While < Base
    attr_accessor :condition, :body
    
    def walk(&bk)
      if yield self
        condition.walk &bk
        body.walk &bk if body
      end
    end
  end
end