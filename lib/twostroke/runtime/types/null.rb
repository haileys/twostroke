module Twostroke::Runtime::Types
  class Null
    def self.null
      @@null ||= new
    end
    
    def to_s
      "null"
    end
  end
end