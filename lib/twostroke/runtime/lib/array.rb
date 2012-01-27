module Twostroke::Runtime
  Lib.register do |scope|
    ary = Types::Array.constructor_function
    scope.set_var "Array", ary
    
    proto = Types::Object.new
    # Array.prototype.toString
    proto.proto_put "toString", Types::Function.new(->(scope, this, args) do
        Lib.throw_type_error "Array.prototype.toString is not generic" unless this.is_a?(Types::Array)
        Types::String.new this.items.map { |o| 
            if o.nil? || o.is_a?(Types::Undefined) || o.is_a?(Types::Null)
              ""
            else
              Types.to_string(o).string
            end
          }.join(",")
      end, nil, "toString", [])
    # Array.prototype.valueOf
    proto.proto_put "valueOf", Types::Function.new(->(scope, this, args) { this }, nil, "valueOf", [])
    # Array.prototype.pop
    proto.proto_put "pop", Types::Function.new(->(scope, this, args) {
      Lib.throw_type_error "Array.prototype.pop is not generic" unless this.is_a? Types::Array
      this.items.pop || Types::Undefined.new
    }, nil, "pop", [])
    # Array.prototype.shift
    proto.proto_put "shift", Types::Function.new(->(scope, this, args) {
      Lib.throw_type_error "Array.prototype.shift is not generic" unless this.is_a? Types::Array
      this.items.shift || Types::Undefined.new
    }, nil, "shift", [])
    # Array.prototype.push
    proto.proto_put "push", Types::Function.new(->(scope, this, args) {
      Lib.throw_type_error "Array.prototype.push is not generic" unless this.is_a? Types::Array
      args.each { |a| this.items.push a }
      Types::Number.new this.items.size
    }, nil, "push", [])
    # Array.prototype.unshift
    proto.proto_put "unshift", Types::Function.new(->(scope, this, args) {
      Lib.throw_type_error "Array.prototype.unshift is not generic" unless this.is_a? Types::Array
      args.each { |a| this.items.unshift a }
      Types::Number.new this.items.size
    }, nil, "unshift", [])
    # Array.prototype.slice
    proto.proto_put "slice", Types::Function.new(->(scope, this, args) {
      begin_index = Types.to_number(args[0] || Types::Undefined.new)
      end_index = Types.to_number(args[1] || Types::Undefined.new)
      begin_index = Types::Number.new(0) if begin_index.nan? || begin_index.infinite?
      if end_index.nan? || end_index.infinite?
        Types::Array.new(this.generic_items[begin_index.number.to_i..-1] || [])
      else
        Types::Array.new(this.generic_items[begin_index.number.to_i...end_index.number.to_i] || [])
      end
    }, nil, "slice", [])
    # Array.prototype.splice
    proto.proto_put "splice", Types::Function.new(->(scope, this, args) {
        Lib.throw_type_error "Array.prototype.splice is not generic" unless this.is_a? Types::Array
        idx = Types.to_uint32(args[0] || Types::Undefined.new)
        count = args[1] && Types.to_uint32(args[1])
        if count and count >= 0
          retn = this.items[idx...(idx + count)]
          this.items[idx...(idx + count)] = args.drop(2)
        else
          retn = this.items[idx..-1]
          this.items[idx..-1] = args.drop(2)
        end
        Types::Array.new retn
      }, nil, "splice", [])
    # Array.prototype.sort
    proto.proto_put "sort", Types::Function.new(->(scope, this, args) {
      Lib.throw_type_error "Array.prototype.sort is not generic" unless this.is_a? Types::Array
      sortfn = args[0] || ->(scope, this, args) { Types::Number.new(Types.to_string(args[0]).string <=> Types.to_string(args[1]).string) }
      this.items.reject!(&:nil?)
      this.items.sort! { |a,b| Types.to_number(sortfn.(scope, this, [a,b])).number }
      this
    }, nil, "sort", [])
    # Array.prototype.length
    proto.define_own_property "length", get: ->(this) { Types::Number.new this.items.size }
    ary.proto_put "prototype", proto
  end
end