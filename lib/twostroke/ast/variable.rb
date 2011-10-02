module Twostroke::AST
  class Variable < Base
    attr_accessor :name
    
    def collapse
      self
    end
  end
end