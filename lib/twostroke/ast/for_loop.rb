module Twostroke::AST
  class ForLoop < Base
    attr_accessor :initializer, :condition, :increment, :body
    
    def collapse
      self.class.new initializer: initializer && initializer.collapse,
        condition: condition && condition.collapse,
        increment: increment && increment.collapse,
        body: body && body.collapse
    end
    
    def walk(&bk)
      if yield self
        initializer.walk(&bk) if initializer
        condition.walk(&bk) if condition
        increment.walk(&bk) if increment
        body.walk &bk if body
      end
    end
  end
end