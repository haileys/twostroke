module Twostroke::AST
  class With < Base
    attr_accessor :object, :statement
    
    def collapse
      self.class.new object: object.collapse, statement: statement && statement.collapse
    end
    
    def walk(&bk)
      if yield self
        object.walk &bk
        statement.walk &bk
      end
    end
  end
end