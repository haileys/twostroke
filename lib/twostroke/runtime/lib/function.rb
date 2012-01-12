module Twostroke::Runtime
  Lib.register do |scope|
    obj = Types::Function.constructor_function
    scope.set_var "Function", obj
    
    proto = Types::Object.new
    proto.proto_put "valueOf", Types::Function.new(->(scope, this, args) { this }, nil, "valueOf", [])
    proto.define_own_property "arity", get: ->(this) { this.arguments.size }, writable: false
    proto.define_own_property "length", get: ->(this) { this.arguments.size }, writable: false
    proto.define_own_property "name", get: ->(this) { this.name }, writable: false
    # Function.prototype.apply
    proto.proto_put "apply", Types::Function.new(->(scope, this, args) do
        Lib.throw_type_error "cannot call Function.prototype.apply on non-callable object" unless this.respond_to?(:call)
        if args[0].nil? || args[0].is_a?(Types::Null) || args[0].is_a?(Types::Undefined)
          call_this = scope.global_scope.root_object
        else
          call_this = Types.to_object(args[0])
        end
        call_args = args[1].is_a?(Types::Object) ? args[1].generic_items : []
        this.call scope, call_this, call_args
      end, nil, "apply", [])
    # Function.prototype.call
    proto.proto_put "call", Types::Function.new(->(scope, this, args) do
        Lib.throw_type_error "cannot call Function.prototype.call on non-callable object" unless this.respond_to?(:call)
        if args[0].nil? || args[0].is_a?(Types::Null) || args[0].is_a?(Types::Undefined)
          call_this = scope.global_scope.root_object
        else
          call_this = Types.to_object(args[0])
        end
        this.call(scope, call_this, args[1..-1])
      end, nil, "call", [])
    # Function.prototype.toString
    proto.proto_put "toString", Types::Function.new(->(scope, this, args) do
        this.primitive_value
      end, nil, "toString", [])
    obj.proto_put "prototype", proto
  end
end