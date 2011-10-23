module Twostroke::Runtime::Types
  class Array < Object
    attr_accessor :items
    
    def initialize(items = [])
      @items = items
      super()
    end
    
    def constructor
      unless defined?(@@constructor)
        @@constructor = Function.new nil, name: "Array" do |this, *args|
          if args.size > 1
            Array.new arg
          else
            Array.new
          end
        end
        proto = Object.new
        proto.properties["length"] = {
          setter: ->(this, val) do
            pval = Types.promote_primitive val
            len = Types.to_number(pval).number
            if len < -1 || len.is_a?(Float) || (len.zero? && !(pval.is_a?(Number) || (val.is_a?(String) && val.string =~ /\A0/)))
              raise Twostroke::Runtime::RuntimeError, "RangeError: invalid_array_length"
            end
            if len < this.items.size
              this.items = this.items[0...len]
            end
          end,
          getter: ->(this) { this.items.size }
        }
        proto.set("pop", Function.new(->(this, args) do
          if this.is_a?(Array)
            this.items.pop
          end
        end))
        proto.set("push", Function.new(->(this, args) do
          if this.is_a?(Array)
            args.each { |arg| this.items.push arg }
            this.items.size
          end
        end))
        proto.set("reverse", Function.new(->(this, args) do
          if this.is_a?(Array)
            Array.new this.items.reverse
          end
        end))
        # more to come...
        @@constructor.set "prototype", proto
      end
      @@constructor
    end
    
    def to_s
      items.join ","
    end
    
    def get(prop)
      prop = prop.to_s
      if prop =~ /\A\d+\z/
        items[prop.to_i]
      else
        super prop
      end
    end
    
    def set(prop, val)
      prop = prop.to_s
      if prop =~ /\A\d+\z/
        items[prop.to_i] = val
      else
        super prop, val
      end
    end
  end
end