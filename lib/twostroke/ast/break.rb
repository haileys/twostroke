module Twostroke::AST
  class Break < Base
    def collapse
      self
    end
  end
end