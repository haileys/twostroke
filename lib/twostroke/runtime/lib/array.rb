module Twostroke::Runtime
  Lib.register do |scope|
    ary = Types::Array.constructor_function
    scope.set_var "Array", ary
    
    proto = Types::Object.new
    # Array.prototype.toString
    proto.put "toString", Types::Function.new(->(scope, this, args) do
        Lib.throw_type_error "Array.prototype.toString is not generic" unless this.is_a?(Types::Array)
        Types::String.new this.items.map { |o| Types.to_string(o).string }.join(",")
      end, nil, "toString", [])
    # Array.prototype.valueOf
    proto.put "valueOf", Types::Function.new(->(scope, this, args) { this }, nil, "valueOf", [])
    # Array.prototype.pop
    proto.put "pop", Types::Function.new(->(scope, this, args) {
      Lib.throw_type_error "Array.prototype.pop is not generic" unless this.is_a? Types::Array
      this.items.pop || Types::Undefined.new
    }, nil, "pop", [])
    # Array.prototype.push
    proto.put "push", Types::Function.new(->(scope, this, args) {
      Lib.throw_type_error "Array.prototype.push is not generic" unless this.is_a? Types::Array
      args.each { |a| this.items.push a }
      Types::Number.new this.items.size
    }, nil, "push", [])
    # Array.prototype.slice
    proto.put "slice", Types::Function.new(->(scope, this, args) {
      Lib.throw_type_error "Array.prototype.slice is not generic" unless this.is_a? Types::Array
      begin_index = Types.to_number(args[0] || Undefined.new)
      end_index = Types.to_number(args[1] || Undefined.new)
      Lib.throw_range_error "invalid array index" if begin_index.nan? || begin_index.infinite?
      if end_index.nan? || end_index.infinite?
        Types::Array.new this.items[begin_index.number.to_i..-1]
      else
        Types::Array.new this.items[begin_index.number.to_i..end_index.number.to_i]
      end
    }, nil, "slice", [])
    # Array.prototype.length
    proto.define_own_property "length", get: ->(this) { Types::Number.new this.items.size }, set: ->(this,val) do
        Lib.throw_type_error "Array.prototype.length is not generic" unless this.is_a? Types::Array
        len = Types.to_number(val)
        Lib.throw_range_error "invalid array length" if len.nan? || len.number < 0 || (len.number % 1) != 0
        this.items = this.items[0...len.number.to_i]
        len
      end, writable: true
    ary.put "prototype", proto
  end
end