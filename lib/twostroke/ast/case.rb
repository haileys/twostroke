module Twostroke::AST
  class Case < Base
    attr_accessor :expression, :statements
    def initialize(*args)
      @statements = []
      super *args
    end
    def collapse
      self.class.new expression: expression.collapse, statements: statements.collect(&:collapse)
    end
  end
end