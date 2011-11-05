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
      
      def has_property(prop)
        if prop =~ /\A\d+\z/
          i = prop.to_i
          i >= 0 && i < items.size
        else
          super prop
        end
      end
      
      def has_own_property(prop)
        if prop =~ /\A\d+\z/
          i = prop.to_i
          i >= 0 && i < items.size
        else
          super prop
        end
      end
      
      def each_enumerable_property(&bk)
        (0...items.size).map(&:to_s).each &bk
        super &bk
      end
    end
  end
end