module Twostroke::Runtime
  Lib.register do |scope|
    regexp = Types::RegExp.constructor_function
    scope.set_var "RegExp", regexp
    proto = Types::Object.new
    proto.proto_put "toString", Types::Function.new(->(scope, this, args) {
        Lib.throw_type_error "RegExp.prototype.toString is not generic" unless this.is_a?(Types::RegExp)
        this.primitive_value
      }, nil, "toString", [])
    proto.define_own_property "global", get: ->(this) {
        Types::Boolean.new this.regexp.global
      }, writable: false, enumerable: false, configurable: false
    proto.define_own_property "ignoreCase", get: ->(this) {
        Types::Boolean.new((this.regexp.options & Regexp::IGNORECASE) != 0)
      }, writable: false, enumerable: false, configurable: false
    proto.define_own_property "multiline", get: ->(this) {
        Types::Boolean.new((this.regexp.options & Regexp::MULTILINE) != 0)
      }, writable: false, enumerable: false, configurable: false
    proto.define_own_property "source", get: ->(this) {
        Types::String.new this.regexp.source
      }, writable: false, enumerable: false, configurable: false
    proto.proto_put "test", Types::Function.new(->(scope, this, args) {
        Lib.throw_type_error "RegExp.prototype.test is not generic" unless this.is_a?(Types::RegExp)
        Types::Boolean.new((Types.to_string(args[0] || Undefined.new).string =~ this.regexp) != nil)
      }, nil, "test", [])
    regexp.proto_put "prototype", proto
  end
end