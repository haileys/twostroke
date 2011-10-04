module Twostroke::AST
  class ForLoop < Base
    attr_accessor :initializer, :condition, :increment, :body
    
    def collapse
      self.class.new initializer: initializer.collapse, condition: condition.collapse, increment: increment.collapse, body: body.collapse
    end
  end
end