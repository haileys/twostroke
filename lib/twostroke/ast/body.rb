module Twostroke::AST
  class Body < Base
    attr_accessor :statements
    
    def initialize(*args)
      @statements = []
      super *args
    end
    
    def walk(&bk)
      if yield self
        statements.each { |s| s.walk &bk }
      end
    end
  end
end