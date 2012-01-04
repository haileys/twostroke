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
        Types::Boolean.new this.global
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
    proto.proto_put "exec", Types::Function.new(->(scope, this, args) {
        re = this.is_a?(Types::RegExp) ? this : Types::RegExp.constructor_function.(nil, nil, this)
        str = Types.to_string(args[0] || Types::Undefined.new).string
        md = re.regexp.match str
        result = Types::Array.new md.to_a.map { |s| Types::String.new s }
        result.put "index", Types::Number.new(md.offset(0).first)
        result.put "input", Types::String.new(str)
        result
      }, nil, "exec", [])
    regexp.proto_put "prototype", proto
  end
end