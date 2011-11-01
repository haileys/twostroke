module Twostroke::Runtime
  Lib.register do |scope|
    proto = Types::Object.new
  
    obj = Types::Function.new(->(scope, this, args) { args.length.zero? ? Types::Object.new : Types.to_object(args[0]) }, nil, "Object", [])
    obj.prototype = proto
    obj.put "prototype", proto
    scope.set_var "Object", obj
    
    proto.put "toString", Types::Function.new(->(scope, this, args) { Types::String.new "[object #{this._class || "Object"}]" }, nil, "toString", [])
    proto.put "valueOf", Types::Function.new(->(scope, this, args) { this }, nil, "valueOf", [])
    proto.put "hasOwnProperty", Types::Function.new(->(scope, this, args) {
      Types::Boolean.new Types.to_object(this).has_own_property(Types.to_string(args[0]).string)
    }, nil, "hasOwnProperty", [])
    proto.put "isPrototypeOf", Types::Function.new(->(scope, this, args) {
      proto = Types.to_object(args[0]).prototype
      this = Types.to_object(this)
      while proto.is_a?(Types::Object)
        return Boolean.new(true) if this == proto
        proto = proto.prototype
      end
      Boolean.new false
    }, nil, "isPrototypeOf", [])
    proto.put "propertyIsEnumerable", Types::Function.new(->(scope, this, args) {
      this = Types.to_object(this)
      prop = Types.to_string(args[0]).string
      if this.has_accessor(prop)
        Boolean.new this.accessors[prop][:enumerable]
      elsif this.has_property
        Boolean.new true
      else
        Boolean.new false
      end
    }, nil, "propertyIsEnumerable", [])
    
    Types::Object.set_global_prototype proto
  end
end