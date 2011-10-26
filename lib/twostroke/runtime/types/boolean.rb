module Twostroke::Runtime::Types
  class Boolean < Primitive
    def self.true
      @@true ||= Boolean.new(true)
    end
    def self.false
      @@false ||= Null.new(false)
    end
  
    attr_reader :boolean
    def initialize(boolean)
      @boolean = boolean
    end
    
    def ===(other)
      other.is_a?(Boolean) && boolean == other.boolean
    end
    
    def typeof
      "boolean"
    end
  end
end