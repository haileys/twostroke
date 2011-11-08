module Twostroke::Runtime::Types
  class Number < Primitive    
    attr_reader :number
    def initialize(number)
      @number = number
    end
    
    def ===(other)
      if number.zero? && other.is_a?(Number) && other.number.zero?
        # in javascript, -0 and 0 are not equal
        # in ruby they are, and the only way to check if a number is -0 is with #to_s
        # please correct me if there's a better way
        number.to_s[0] == other.number.to_s[0]
      else
        other.is_a?(Number) && number == other.number
      end
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