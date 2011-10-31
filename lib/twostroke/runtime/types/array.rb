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
    
      attr_accessor :items
      def initialize(items = [])
        @prototype = Array.constructor_function.get("prototype")
        super()
        @items = items
      end
      
      def length
        items.size
      end
      
      def get(prop, this = self)
        if prop =~ /\A\d+\z/
          items[prop.to_i]
        else
          super prop, this
        end
      end
      
      def put(prop, val, this = self)
        if prop =~ /\A\d+\z/
          items[prop.to_i] = val
        else
          super prop, val, this
        end
      end
    end
  end
end