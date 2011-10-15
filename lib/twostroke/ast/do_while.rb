module Twostroke::AST
  class DoWhile < Base
    attr_accessor :body, :condition
    
    def collapse
      self.class.new body: body.collapse, condition: condition.collapse
    end
  end
end