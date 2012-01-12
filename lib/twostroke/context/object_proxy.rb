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
        unless val.is_a? Twstroke::Runtime::Types::Value
          val = Twostroke::Runtime::Types.marshal val
        end
        @object.put prop.to_s, val
      end
      
      def method_missing(prop, *args, &block)
        return self[prop] = args[0] if prop =~ /=\z/
        val = self[prop]
        if val.respond_to? :call
          val.call(self, *args)
        elsif args.size > 0
          raise "Cannot call non-callable"
        else
          val
        end
      end
    end
  end
end