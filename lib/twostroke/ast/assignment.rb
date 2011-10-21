module Twostroke::AST
  class Assignment < Base
    attr_accessor :left, :right
    
    def collapse
      self.class.new left: left.collapse, right: right.collapse
    end
    
    def walk(&bk)
      if yield self
        left.walk &bk
        right.walk &bk
      end
    end
  end
end