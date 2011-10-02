module Twostroke::AST
  class Function < Base
    attr_accessor :name, :arguments, :statements
    
    def initialize(*args)
      @arguments = []
      @statements = []
      super *args
    end
    
    def collapse
      new name: name, arguments: arguments, statements: statements.reject(&:nil?).map(:collapse)
    end
  end
end