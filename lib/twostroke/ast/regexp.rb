module Twostroke::AST
  class Regexp < Base
    attr_accessor :regexp
    
    def collapse
      self
    end
    
    def walk(&bk)
      yield self
    end
  end
end