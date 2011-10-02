module Twostroke::AST
  class BinaryNot < Base
    attr_accessor :value
    
    def collapse
      self.class.new value: value.collapse
    end
  end
end