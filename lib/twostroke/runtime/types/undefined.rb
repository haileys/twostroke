module Twostroke::Runtime::Types
  class Undefined < Primitive
    def self.new
      @@undefined ||= Undefined.allocate
    end
    
    def ===(other)
      other.is_a?(Undefined)
    end
    
    def typeof
      "undefined"
    end
  end
end