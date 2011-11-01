module Twostroke::Runtime
  Lib.register do |scope|
    obj = Types::BooleanObject.constructor_function
    scope.set_var "Boolean", obj
    
    proto = Types::Object.new
    proto.put "toString", Types::Function.new(->(scope, this, args) {
      if this.is_a?(Types::BooleanObject)
        Types::String.new(this.boolean.to_s)
      else
        Lib.throw_type_error "Boolean.prototype.toString is not generic"
      end
    }, nil, "toString", [])
    proto.put "valueOf", Types::Function.new(->(scope, this, args) {
      if this.is_a?(Types::BooleanObject)
        Types::Boolean.new(this.boolean)
      else
        Types.to_primitive(this)
      end
    }, nil, "valueOf", [])
    obj.put "prototype", proto
  end
end