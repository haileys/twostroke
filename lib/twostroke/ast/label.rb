module Twostroke::AST
  class Label < Base
    attr_accessor :name, :statement
    
    def initialize(*args)
      @statements = []
      super *args
    end
    
    def walk(&bk)
      if yield self
        statement.walk &bk
      end
    end
  end
end