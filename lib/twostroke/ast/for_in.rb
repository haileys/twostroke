module Twostroke::AST
  class ForIn < Base
    attr_accessor :lval, :object, :body
    
    def collapse
      self.class.new lval: lval.collapse, object: object.collapse, body: body.collapse
    end
  end
end