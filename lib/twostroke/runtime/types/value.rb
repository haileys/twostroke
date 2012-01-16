module Twostroke::Runtime::Types
  class Value
    def has_instance(obj)
      Twostroke::Runtime::Lib.throw_type_error "Expected a function in instanceof check"
    end
    
    def to_ruby
      nil
    end
  end
  
  class Primitive < Value
  end
end