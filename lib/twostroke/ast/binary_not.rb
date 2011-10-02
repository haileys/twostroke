module Twostroke::AST
  class BinaryNot < Base
    attr_accessor :value
    
    def collapse
      new value: value.collapse
    end
  end
end