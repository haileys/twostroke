module Twostroke::AST
  class Call < Base
    attr_accessor :callee, :arguments
    
    def initialize(*args)
      @arguments = []
      super *args
    end
    
    def walk(&bk)
      if yield self
        callee.walk &bk
        arguments.each { |arg| arg.walk &bk }
      end
    end
  end
end