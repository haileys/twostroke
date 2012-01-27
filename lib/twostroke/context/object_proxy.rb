module Twostroke
  class Context
    class ObjectProxy < BasicObject
      def initialize(object)
        @object = object
      end
      
      def [](prop)
        o = @object.get(prop.to_s) and o.to_ruby
      end
      
      def []=(prop, val)
        unless val.is_a? ::Twostroke::Runtime::Types::Value
          val = ::Twostroke::Runtime::Types.marshal val
        end
        @object.put prop.to_s, val
      end
      
      def method_missing(prop, *args, &block)
        return self[prop] = args[0] if prop =~ /=\z/
        val = self[prop]
        if val.respond_to? :call
          val.call(*args)
        elsif args.size > 0
          ::Kernel.p args
          ::Kernel.raise "Cannot call non-callable"
        else
          val
        end
      end
      
      def inspect
        if toString = @object.get("toString") and toString.respond_to? :call
          s = toString.call(nil, @object, [])
          if s.is_a? ::Twostroke::Runtime::Types::Primitive
            ::Twostroke::Runtime::Types.to_string(s).string
          end
        end
      end
    end
  end
end