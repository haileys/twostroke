module Twostroke::AST
  class Array < Base
    attr_accessor :items
    
    def initialize(*args)
      @items = []
      super *args
    end
  end
end