module Twostroke::AST
  class False < Base
    def walk(&bk)
      yield self
    end
  end
end