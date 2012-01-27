module Twostroke::AST
  class ForIn < Base
    attr_accessor :lval, :object, :body
    
    def walk(&bk)
      if yield self
        lval.walk &bk
        object.walk &bk
        body.walk &bk
      end
    end
  end
end