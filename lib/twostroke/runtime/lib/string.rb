module Twostroke::Runtime
  Lib.register do |scope|
    obj = Types::StringObject.constructor_function
    scope.set_var "String", obj
    
    proto = Types::Object.new
    proto.put "toString", Types::Function.new(->(scope, this, args) {
      if this.is_a?(Types::StringObject)
        Types::String.new(this.string)
      else
        Lib.throw_type_error "String.prototype.toString is not generic"
      end
    }, nil, "toString", [])
    proto.put "valueOf", Types::Function.new(->(scope, this, args) { this.is_a?(Types::StringObject) ? Types::String.new(this.string) : Types.to_primitive(this) }, nil, "valueOf", [])
    proto.define_own_property "length", get: ->(this) { Types::Number.new this.string.size }, writable: false, enumerable: false
    obj.put "prototype", proto
    
    obj.put "fromCharCode", Types::Function.new(->(scope, this, args) {
      Types::String.new args.map { |a| Types.to_number(a).number.to_i.chr }.join
    }, nil, "fromCharCode", [])
  end
end