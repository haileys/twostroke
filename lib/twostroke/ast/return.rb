module Twostroke::AST
  class Return < Base
    attr_accessor :expression
    
    def collapse
      new expression: expression.collapse
    end
  end
end