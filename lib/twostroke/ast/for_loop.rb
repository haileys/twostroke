module Twostroke::AST
  class ForLoop < Base
    attr_accessor :initializer, :condition, :increment, :body
    
    def collapse
      self.class.new initializer: initializer && initializer.collapse,
        condition: condition && condition.collapse,
        increment: increment && increment.collapse,
        body: body.collapse
    end
    
    def walk(&bk)
      if yield self
        initializer.walk &bk
        condition.walk &bk
        increment.walk &bk
        body.walk &bk
      end
    end
  end
end