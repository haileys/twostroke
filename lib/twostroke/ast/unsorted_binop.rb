module Twostroke::AST
  class UnsortedBinop < Base
    attr_accessor :left, :op, :right
  end
end