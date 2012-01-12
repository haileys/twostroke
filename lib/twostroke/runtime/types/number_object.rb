module Twostroke::Runtime::Types
  class NumberObject < Object
    def self.constructor_function
      @@constructor_function ||=
        Function.new(->(scope, this, args) {
          if this.constructing?
            Twostroke::Runtime::Types.to_object(Twostroke::Runtime::Types.to_number(args[0] || Undefined.new))
          else
            Twostroke::Runtime::Types.to_number(args[0])
          end
        }, nil, "Number", [])
    end
    
    attr_reader :number
    def initialize(number)
      @number = number
      @prototype = NumberObject.constructor_function.get("prototype")
      super()
    end
    
    def to_ruby
      number
    end
    
    def primitive_value
      Number.new number
    end
  end
end