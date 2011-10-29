module Twostroke::Runtime
  module Types
    class StringObject < Object
      def self.constructor_function
        @@constructor_function ||=
          Function.new(->(scope, this, args) { this.constructing? ? Types.to_object(Types.to_string(args[0] || Undefined.new)) : Types.to_string(args[0]) }, nil, "String", [])
      end
    
      def prototype
        @prototype ||= StringObject.constructor_function.get("prototype")
      end
    
      attr_reader :string
      def initialize(string)
        @string = string
        super()
      end
    
      def primitive_value
        String.new string
      end
    end
  end
end