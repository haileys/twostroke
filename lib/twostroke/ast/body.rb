module Twostroke::AST
  class Body < Base
    attr_accessor :statements
    
    def initialize(*args)
      @statements = []
      super *args
    end
    
    def collapse
      self.class.new statements: statements.reject(&:nil?).map(&:collapse)
    end
  end
end