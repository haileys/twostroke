module Twostroke::AST
  class Break < Base
    attr_accessor :label
    
    def collapse
      self
    end
    
    def walk
      yield self
    end
  end
end