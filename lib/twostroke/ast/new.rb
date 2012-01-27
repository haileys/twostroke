module Twostroke::AST
  class New < Base
    attr_accessor :callee, :arguments
    
    def initialize(*args)
      @arguments = []
      super *args
    end
    
    def walk(&bk)
      if yield self
        callee.walk &bk
        arguments.each { |a| a.walk &bk }
      end
    end
  end
end