module Twostroke::AST
  class Regexp < Base
    attr_accessor :regexp
    
    def collapse
      self
    end
  end
end