module Twostroke::Runtime::Types
  class BooleanObject < Object
    def self.constructor_function
      @@constructor_function ||=
        Function.new(->(scope, this, args) { this.constructing? ? Types.to_object(Types.to_boolean(args[0] || Undefined.new)) : Types.to_boolean(args[0]) }, nil, "Boolean", [])
    end
    
    attr_reader :boolean
    def initialize(boolean)
      @prototype = BooleanObject.constructor_function.get("prototype")
      super()
      @boolean = boolean
    end
    
    def primitive_value
      Boolean.new boolean
    end
  end
end