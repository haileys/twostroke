module Twostroke::Runtime::Types
  class NumberObject < Object
    def self.constructor_function
      @@constructor_function ||=
        Function.new(->(scope, this, args) { this.constructing? ? Types.to_object(Types.to_number(args[0] || Undefined.new)) : Types.to_boolean(args[0]) }, nil, "Number", [])
    end
  
    def prototype
      @prototype ||= NumberObject.constructor_function.get("prototype")
    end
    
    attr_reader :number
    def initialize(number)
      @number = number
      super()
    end
    
    def primitive_value
      Number.new number
    end
  end
end