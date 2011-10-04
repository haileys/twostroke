module Twostroke::AST
  class Ternary < Base
    attr_accessor :condition, :if_true, :if_false
    
    def collapse
      self.class.new condition: condition.collapse, if_true: if_true.collapse, if_false: if_false.collapse
    end
  end
end