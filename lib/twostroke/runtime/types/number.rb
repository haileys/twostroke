module Twostroke::Runtime::Types
  class Number < Primitive    
    attr_reader :number
    def initialize(number)
      @number = number
    end
    
    def to_ruby
      number
    end
    
    def ===(other)
      other.is_a?(Number) && number == other.number
    end
    
    def typeof
      "number"
    end
    
    def zero?
      number.zero?
    end
    
    def nan?
      number.is_a?(Float) && number.nan?
    end
    
    def infinite?
      number.is_a?(Float) && number.infinite?
    end
  end
end