module Twostroke::AST
  class Null < Base
    def collapse
      self
    end
  end
end