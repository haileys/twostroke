module Twostroke::AST
  class Debugger < Base
    def walk
      yield self
    end
  end
end