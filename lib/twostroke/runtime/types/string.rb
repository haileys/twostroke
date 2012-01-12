module Twostroke::Runtime::Types
  class String < Primitive
    attr_reader :string
    def initialize(string)
      @string = string
    end
    
    def to_ruby
      string
    end
    
    def ===(other)
      other.is_a?(String) && string == other.string
    end
    
    def typeof
      "string"
    end
  end
end