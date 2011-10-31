module Twostroke::Runtime
  Lib.register do |scope|
    ary = Types::Array.constructor_function
    scope.set_var "Array", ary
    
    proto = Types::Object.new
    # Array.prototype.toString
    proto.put "toString", Types::Function.new(->(scope, this, args) do
        if this.is_a?(Types::Array)
          Types::String.new("[" + this.items.map { |o| Types.to_string(o).string }.join(", ") + "]")
        else
          raise "TypeError: @TODO"
        end
      end, nil, "toString", [])
    # Array.prototype.valueOf
    proto.put "valueOf", Types::Function.new(->(scope, this, args) { this }, nil, "valueOf", [])
    # Array.prototype.pop
    proto.put "pop", Types::Function.new(->(scope, this, args) {
      raise "TypeError @TODO" unless this.is_a? Types::Array
      this.items.pop || Types::Undefined.new
    }, nil, "pop", [])
    # Array.prototype.push
    proto.put "push", Types::Function.new(->(scope, this, args) {
      raise "TypeError @TODO" unless this.is_a? Types::Array
      args.each { |a| this.items.push a }
      Types::Number.new this.items.size
    }, nil, "push", [])
    # Array.prototype.length
    proto.define_own_property "length", get: ->(this) { Types::Number.new this.items.size }, set: ->(this,val) do
        raise "TypeError @TODO" unless this.is_a? Types::Array
        len = Types.to_number(val)
        raise "RangeError: Invalid array length @TODO" if len.nan? || len.number < 0 || (len.number % 1) != 0
        this.items = this.items[0...len.number.to_i]
        len
      end, writable: true
    ary.put "prototype", proto
  end
end