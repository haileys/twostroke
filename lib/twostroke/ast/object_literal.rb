module Twostroke::AST
  class ObjectLiteral < Base
    attr_accessor :items
    
    def initialize(*args)
      @items = []
      super *args
    end
    
    def collapse
      self.class.new items: items.map do |*item|
        k, v = item
        v.collapse
      end
    end
  end
end