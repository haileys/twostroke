module Twostroke::AST
  class Index < Base
    attr_accessor :object, :index
    
    def collapse
      self.class.new object: object.collapse, index: index.collapse
    end
  end
end