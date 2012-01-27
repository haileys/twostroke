module Twostroke::Runtime
  Lib.register do |scope|
    obj = Types::BooleanObject.constructor_function
    scope.set_var "Boolean", obj
    
    proto = Types::Object.new
    proto.proto_put "toString", Types::Function.new(->(scope, this, args) {
        Lib.throw_type_error "Boolean.prototype.valueOf is not generic" unless this.is_a?(Types::BooleanObject)
        Types::String.new(this.boolean.to_s)
      }, nil, "toString", [])
    proto.proto_put "valueOf", Types::Function.new(->(scope, this, args) {
        Lib.throw_type_error "Boolean.prototype.valueOf is not generic" unless this.is_a?(Types::BooleanObject)
        Types::Boolean.new(this.boolean)
      }, nil, "valueOf", [])
    obj.proto_put "prototype", proto
  end
end