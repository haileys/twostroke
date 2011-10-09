module Twostroke::AST
  class Delete < Base
    attr_accessor :expression
    
    def collapse
      self.class.new expression: expression.collapse
    end
  end
end