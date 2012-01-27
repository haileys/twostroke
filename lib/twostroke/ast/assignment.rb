module Twostroke::AST
  class Assignment < Base
    attr_accessor :left, :right
    
    def walk(&bk)
      if yield self
        left.walk &bk
        right.walk &bk
      end
    end
  end
end