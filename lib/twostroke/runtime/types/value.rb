module Twostroke::Runtime::Types
  class Value
    def typeof
      "VALUE"
    end
  end
  
  class Primitive < Value
  end
end