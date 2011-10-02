module Twostroke::AST
  class MemberAccess < Base
    attr_accessor :object, :member
    
    def collapse
      new object: object.collapse, member: member
    end
  end
end