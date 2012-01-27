module Twostroke::AST
  class Break < Base
    attr_accessor :label
    
    def walk
      yield self
    end
  end
end