module Twostroke::Runtime
  module Types
    class Array < Object
      def self.constructor_function
        @@constructor_function ||=
          Function.new(->(scope, this, args) do
              if args.length.zero?
                Array.new
              elsif args.length == 1
                Array.new([nil] * Types.to_uint32(args[0]))
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
        define_own_property "length", get: ->(this) { Types::Number.new this.items.size }, set: ->(this,val) do
            Lib.throw_type_error "Array.prototype.length is not generic" unless this.is_a? Types::Array
            len = Types.to_uint32(val)
            this.items = this.items[0...len]
          end, writable: true, enumerable: false
      end
      
      def to_ruby
        items.map &:to_ruby
      end
      
      def length
        items.size
      end
      
      def get(prop, this = self)
        if prop =~ /\A\d+\z/
          items[prop.to_i] || Undefined.new
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
          i >= 0 && i < items.size && !items[i].nil?
        else
          super prop
        end
      end
      
      def has_own_property(prop)
        if prop =~ /\A\d+\z/
          i = prop.to_i
          i >= 0 && i < items.size && !items[i].nil?
        else
          super prop
        end
      end
      
      def delete(prop)
        if prop =~ /\A\d+\z/
          i = prop.to_i
          if i >= 0 && i < items.size && !items[i].nil?
            items[i] = nil
            return true
          end
        end
        super prop
      end
      
      def each_enumerable_property(&bk)
        (0...items.size).map(&:to_s).each &bk
        super &bk
      end
    end
  end
end