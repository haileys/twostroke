module Twostroke::AST
  class Declaration < Base
    attr_accessor :name
    
    def collapse
      self
    end
    
    def walk
      yield self
    end
  end
end