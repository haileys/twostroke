module Twostroke::AST
  class ObjectLiteral < Base
    attr_accessor :items
    
    def initialize(*args)
      @items = []
      super *args
    end
    
    def walk(&bk)
      if yield self
        items.each { |i| i[1].walk &bk }
      end
    end
  end
end