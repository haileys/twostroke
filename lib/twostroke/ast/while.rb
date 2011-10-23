module Twostroke::AST
  class While < Base
    attr_accessor :condition, :body
    
    def collapse
      self.class.new condition: condition.collapse, body: body && body.collapse
    end
    
    def walk(&bk)
      if yield self
        condition.walk &bk
        body.walk &bk if body
      end
    end
  end
end