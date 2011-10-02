module Twostroke::AST
  class Not < Base
    attr_accessor :value
    
    def collapse
      new value: value.collapse
    end
  end
end