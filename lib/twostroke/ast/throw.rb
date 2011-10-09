module Twostroke::AST
  class Throw < Base
    attr_accessor :expression
    
    def collapse
      self.class.new expression: expression.collapse
    end
  end
end
