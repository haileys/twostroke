module Twostroke::AST
  class Declaration < Base
    attr_accessor :name
    
    def walk
      yield self
    end
  end
end