module Twostroke::AST
  class With < Base
    attr_accessor :object, :statement
    
    def walk(&bk)
      if yield self
        object.walk &bk
        statement.walk &bk
      end
    end
  end
end