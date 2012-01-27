module Twostroke::AST
  class Function < Base
    attr_accessor :name, :arguments, :statements, :fnid, :as_expression
    
    def initialize(*args)
      @arguments = []
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