module Twostroke::AST
  class String < Base
    attr_accessor :string
    
    def collapse
      self
    end
  end
end