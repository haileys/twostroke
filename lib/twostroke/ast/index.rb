module Twostroke::AST
  class Index < Base
    attr_accessor :object, :index
    
    def walk(&bk)
      if yield self
        object.walk &bk
        index.walk &bk
      end
    end
  end
end