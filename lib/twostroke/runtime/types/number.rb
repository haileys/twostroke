module Twostroke::Runtime::Types
  class Number < Primitive    
    attr_reader :number
    def initialize(number)
      @number = number
    end
    
    def ===(other)
      other.is_a?(Number) && number == other.number
    end
    def typeof
      "string"
    end
    def zero?
      number.zero?
    end
    def nan?
      number.is_a?(Float) && number.nan?
    end
  end
end