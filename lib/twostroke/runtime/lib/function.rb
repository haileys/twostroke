module Twostroke::Runtime
  Lib.register do |scope|
    obj = Types::Function.constructor_function
    scope.set_var "Function", obj
    
    proto = Types::Object.new
    proto.put "toString", Types::Function.new(->(scope, this, args) { this.is_a?(Types::Function) ? this.primitive_value : raise("TypeError: @TODO") }, nil, "toString", [])
    proto.put "valueOf", Types::Function.new(->(scope, this, args) { this }, nil, "valueOf", [])
    proto.define_own_property "arity", get: ->(this) { this.arguments.size }, writable: false
    proto.define_own_property "length", get: ->(this) { this.arguments.size }, writable: false
    proto.define_own_property "name", get: ->(this) { this.name }, writable: false
    # Function.prototype.apply
    proto.put "apply", Types::Function.new(->(scope, this, args) do
        raise "TypeError: cannot call Function.prototype.apply on non-callable object" unless this.respond_to?(:call)
        call_this = args[0] || Types::Undefined.new
        call_args = []
        unless args[1].nil? || args[1].is_a?(Types::Null) || args[1].is_a?(Types::Undefined)
          args[1] = Types.to_object(args[1])
          len = args[1].get("length")
          if len.is_a? Types::Number
            (0...Types.to_number(len).number.to_i).each do |i|
              call_args.push args[1].get(i.to_s)
            end
          end
        end
        this.call scope, call_this, call_args
      end, nil, "apply", [])
    # Function.prototype.bind
    proto.put "bind", Types::Function.new(->(scope, this, args) do
        raise "TypeError: cannot call Function.prototype.bind on non-callable object" unless this.respond_to?(:call)
        Types::Function.new(->(_scope, _this, _args) do
          this.call(_scope, args.first || Undefined.new, args.drop(1) + _args)
        end, nil, nil, [])
      end, nil, "bind", [])
    obj.put "prototype", proto
    
    obj.put "fromCharCode", Types::Function.new(->(scope, this, args) {
      Types::String.new args.map { |a| Types.to_number(a).number.to_i.chr }.join
    }, nil, "fromCharCode", [])
  end
end