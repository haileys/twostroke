module Twostroke::AST
  class Null < Base
    def walk
      yield self
    end
  end
end