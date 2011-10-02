module Twostroke::AST
  class Number < Base
    attr_accessor :number
    
    def collapse
      self
    end
  end
end