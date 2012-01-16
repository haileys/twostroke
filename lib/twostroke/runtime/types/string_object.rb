module Twostroke::Runtime
  module Types
    class StringObject < Object
      def self.constructor_function
        @@constructor_function ||=
          Function.new(->(scope, this, args) { this.constructing? ? Types.to_object(Types.to_string(args[0] || Undefined.new)) : Types.to_string(args[0]) }, nil, "String", [])
      end
    
      attr_reader :string
      def initialize(string)
        @prototype = StringObject.constructor_function.get("prototype")
        @string = string
        super()
      end
      
      def to_ruby
        string
      end
      
      def get(prop, this = self)
        if prop =~ /\A\d+\z/
          idx = prop.to_i
          unless idx < 0 or idx >= string.length
            String.new string[idx]
          end
        else
          super prop, this
        end
      end
      
      def has_property(prop)
        if prop =~ /\A\d+\z/
          i = prop.to_i
          i >= 0 && i < string.size
        else
          super prop
        end
      end
      
      def has_own_property(prop)
        if prop =~ /\A\d+\z/
          i = prop.to_i
          i >= 0 && i < string.size
        else
          super prop
        end
      end
      
      def each_enumerable_property(&bk)
        (0...string.length).map(&:to_s).each &bk
        super &bk
      end
    end
  end
end