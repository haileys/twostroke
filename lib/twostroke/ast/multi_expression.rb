module Twostroke::AST
  class MultiExpression < Base
    attr_accessor :left, :right
    
    def collapse
      self.class.new left: left.collapse, right: right.collapse
    end
  end
end