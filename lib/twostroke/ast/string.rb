module Twostroke::AST
  class String < Base
    attr_accessor :string
    
    def collapse
      self
    end
    
    def walk
      yield self
    end
  end
end