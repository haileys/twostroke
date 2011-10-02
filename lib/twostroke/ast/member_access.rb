module Twostroke::AST
  class MemberAccess < Base
    attr_accessor :object, :member
    
    def collapse
      self.class.new object: object.collapse, member: member
    end
  end
end