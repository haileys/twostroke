module Twostroke::AST
  class Declaration < Base
    attr_accessor :name
    
    def collapse
      self
    end
  end
end