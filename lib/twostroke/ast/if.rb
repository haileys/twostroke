module Twostroke::AST
  class If < Base
    attr_accessor :condition, :then, :else
  end
end