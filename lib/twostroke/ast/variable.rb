module Twostroke::AST
  class Variable < Base
    attr_accessor :name
    
    def collapse
      self
    end
    
    def walk
      yield self
    end
  end
end