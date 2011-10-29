module Twostroke::Runtime
  Lib.register do |scope|
    ary = Types::Array.constructor_function
    scope.set_var "Array", ary
    
    proto = Types::Object.new
    proto.put "toString", Types::Function.new(->(scope, this, args) do
        if this.is_a?(Types::Array)
          Types::String.new("[" + this.items.map { |o| Types.to_string(o).string }.join(", ") + "]")
        else
          raise "TypeError: @TODO"
        end
      end, nil, "toString", [])
    proto.put "valueOf", Types::Function.new(->(scope, this, args) { this }, nil, "valueOf", [])
    proto.define_own_property "length", get: ->(this) { Types::Number.new this.items.size }, set: ->(this,val) do
        len = Types.to_number(val)
        raise "RangeError: Invalid array length @TODO" if len.nan? || len.number < 0 || (len.number % 1) != 0
        if len.number < this.items.size
          len.number.to_i.upto(this.length) { |i| this.delete i.to_s }
          this.length = len.number.to_i
        end        
      end, writable: true
    ary.put "prototype", proto
  end
end