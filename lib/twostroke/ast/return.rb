module Twostroke::AST
  class Return < Base
    attr_accessor :expression
    
    def collapse
      self.class.new expression: expression.collapse
    end
  end
end