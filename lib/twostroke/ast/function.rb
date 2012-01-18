module Twostroke::AST
  class Function < Base
    attr_accessor :name, :arguments, :statements, :fnid, :is_block
    
    def initialize(*args)
      @arguments = []
      @statements = []
      super *args
    end
    
    def collapse
      self.class.new name: name, arguments: arguments, statements: statements.reject(&:nil?).map(&:collapse), fnid: fnid, is_block: is_block
    end
    
    def walk(&bk)
      if yield self
        statements.each { |s| s.walk &bk }
      end
    end
  end
end