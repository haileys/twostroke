module Twostroke::AST
  class Variable < Base
    attr_accessor :name
    
    def walk
      yield self
    end
  end
end