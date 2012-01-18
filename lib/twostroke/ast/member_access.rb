module Twostroke::AST
  class MemberAccess < Base
    attr_accessor :object, :member
    
    def walk(&bk)
      if yield self
        object.walk &bk
      end
    end
  end
end