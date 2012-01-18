module Twostroke::AST
  class True < Base
    def walk(&bk)
      yield self
    end
  end
end