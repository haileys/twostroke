module Twostroke::Runtime::Types
  class Value
    def typeof
      "VALUE"
    end
    
    def has_instance(obj)
      Twostroke::Runtime::Lib.throw_type_error "Expected a function in instanceof check"
    end
  end
  
  class Primitive < Value
  end
end