module Twostroke::Runtime
  module Types
    class Array < Object
      def self.constructor_function
        @@constructor_function ||=
          Function.new(->(scope, this, args) do
              if args.length <= 1
                Array.new
              else
                Array.new args
              end
            end, nil, "Array", [])
      end
      
      def items
        (0...@length).map { |idx| get idx.to_s }
      end
  
      def prototype
        @prototype ||= Array.constructor_function.get("prototype")
      end
    
      attr_accessor :length
      def initialize(items = [])
        @length = items.size
        super()
        (0...@length).each { |i| put i.to_s, items[i] }
      end
    
      def primitive_value
        String.new string
      end
    end
  end
end