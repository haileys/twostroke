module Twostroke::AST
  class Case < Base
    attr_accessor :expression, :statements
    def initialize(*args)
      @statements = []
      @is_default = false
      super *args
    end
    
    def walk(&bk)
      if yield self
        expression.walk &bk if expression
        statements.each { |s| s.walk &bk }
      end
    end
  end
end