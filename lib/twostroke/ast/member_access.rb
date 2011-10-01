module Twostroke::AST
  class MemberAccess < Base
    attr_accessor :object, :member
  end
end