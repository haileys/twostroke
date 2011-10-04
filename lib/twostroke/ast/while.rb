module Twostroke::AST
  class While < Base
    attr_accessor :condition, :body
    
    def collapse
      self.class.new condition: condition.collapse, body: body.collapse
    end
  end
end