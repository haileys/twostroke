module Twostroke::AST
  class Continue < Base
    attr_accessor :label
    
    def walk
      yield self
    end
  end
end