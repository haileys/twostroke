module Twostroke::AST
  class Switch < Base
    attr_accessor :expression, :cases
    def initialize(*args)
      @cases = []
      super *args
    end
    def collapse
      self.class.new expression: expression.collapse, cases: cases.collect(&:collapse)
    end
  end
end