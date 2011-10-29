module Twostroke::Runtime
  Lib.register do |scope|
    obj = Types::BooleanObject.constructor_function
    scope.set_var "Boolean", obj
    
    proto = Types::Object.new
    proto.put "toString", Types::Function.new(->(scope, this, args) { this.is_a?(Types::BooleanObject) ? Types::String.new(this.boolean.to_s) : raise("TypeError: @TODO") }, nil, "toString", [])
    proto.put "valueOf", Types::Function.new(->(scope, this, args) { this.is_a?(Types::BooleanObject) ? Types::Boolean.new(this.boolean) : Types.to_primitive(this) }, nil, "valueOf", [])
    obj.put "prototype", proto
  end
end