module Twostroke::AST
  class Body < Base
    attr_accessor :statements
    
    def initialize(*args)
      @statements = []
      super *args
    end
  end
end