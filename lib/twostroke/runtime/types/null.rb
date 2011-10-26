module Twostroke::Runtime::Types
  class Null < Primitive
    def self.new
      @@null ||= Null.allocate
    end
    
    def ===(other)
      other.is_a?(Null)
    end
    
    def typeof
      "object"
    end
  end
end