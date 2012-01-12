module Twostroke::Runtime::Types
  class BooleanObject < Object
    def self.constructor_function
      @@constructor_function ||=
        Function.new(->(scope, this, args) { 
          if this.constructing?
            Twostroke::Runtime::Types.to_object(Twostroke::Runtime::Types.to_boolean(args[0] || Undefined.new))
          else
            Twostroke::Runtime::Types.to_boolean(args[0])
          end
        }, nil, "Boolean", [])
    end
    
    attr_reader :boolean
    def initialize(boolean)
      @prototype = BooleanObject.constructor_function.get("prototype")
      super()
      @boolean = boolean
    end
    
    def to_ruby
      boolean
    end
    
    def primitive_value
      Boolean.new boolean
    end
  end
end