module Twostroke::AST
  class Case < Base
    attr_accessor :expression, :statements
    def initialize(*args)
      @statements = []
      @is_default = false
      super *args
    end
    def collapse
      self.class.new expression: expression && expression.collapse, statements: statements.collect(&:collapse)
    end
    
    def walk(&bk)
      if yield self
        expression.walk &bk
        statements.each { |s| s.walk &bk }
      end
    end
  end
end