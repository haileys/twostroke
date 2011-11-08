module Twostroke::Runtime
  Lib.register do |scope|
    regexp = Types::RegExp.constructor_function
    scope.set_var "RegExp", regexp
    proto = Types::Object.new
    proto.proto_put "toString", Types::Function.new(->(scope, this, args) {
        Lib.throw_type_error "RegExp.prototype.toString is not generic" unless this.is_a?(Types::RegExp)
        this.primitive_value
      }, nil, "toString", [])
    regexp.proto_put "prototype", proto
  end
end