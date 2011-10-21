module Twostroke::AST
  class ObjectLiteral < Base
    attr_accessor :items
    
    def initialize(*args)
      @items = []
      super *args
    end
    
    def collapse
      collapsed = items.map { |k,v| [k, v.collapse] }
      self.class.new items: collapsed
    end
    
    def walk(&bk)
      if yield self
        items.each { |i| i[1].walk &bk }
      end
    end
  end
end