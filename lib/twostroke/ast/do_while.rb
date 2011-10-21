module Twostroke::AST
  class DoWhile < Base
    attr_accessor :body, :condition
    
    def collapse
      self.class.new body: body.collapse, condition: condition.collapse
    end
    
    def walk(&bk)
      if yield self
        condition.walk &bk
        body.walk &bk
      end
    end
  end
end