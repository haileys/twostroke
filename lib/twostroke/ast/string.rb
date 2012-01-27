module Twostroke::AST
  class String < Base
    attr_accessor :string
    
    def walk
      yield self
    end
  end
end