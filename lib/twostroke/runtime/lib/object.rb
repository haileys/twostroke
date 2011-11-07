module Twostroke::Runtime
  Lib.register do |scope|
    proto = Types::Object.new
  
    obj = Types::Function.new(->(scope, this, args) { args.length.zero? ? Types::Object.new : Types.to_object(args[0]) }, nil, "Object", [])
    #obj.prototype is Function, lets set its prototype to proto
    obj.prototype.prototype = proto
    obj.put "prototype", proto
    scope.set_var "Object", obj
    
    proto.put "toString", Types::Function.new(->(scope, this, args) {
      if this.is_a? Types::Primitive
        Types.to_string(this).string
      else
        Types::String.new "[object #{this._class ? this._class.name : "Object"}]"
      end
    }, nil, "toString", [])
    proto.put "valueOf", Types::Function.new(->(scope, this, args) { this }, nil, "valueOf", [])
    proto.put "hasOwnProperty", Types::Function.new(->(scope, this, args) {
      Types::Boolean.new Types.to_object(this || Types::Undefined.new).has_own_property(Types.to_string(args[0] || Types::Undefined.new).string)
    }, nil, "hasOwnProperty", [])
    proto.put "isPrototypeOf", Types::Function.new(->(scope, this, args) {
      if args[0].is_a? Types::Object
        proto = args[0].prototype
        this = Types.to_object(this || Types::Undefined.new)
        while proto.is_a?(Types::Object)
          return Types::Boolean.new(true) if this == proto
          proto = proto.prototype
        end
      end
      Types::Boolean.new false
    }, nil, "isPrototypeOf", [])
    proto.put "propertyIsEnumerable", Types::Function.new(->(scope, this, args) {
      this = Types.to_object(this || Types::Undefined.new)
      prop = Types.to_string(args[0] || Types::Undefined.new).string
      if this.has_accessor(prop)
        Types::Boolean.new this.accessors[prop][:enumerable]
      elsif this.has_property
        Types::Boolean.new true
      else
        Types::Boolean.new false
      end
    }, nil, "propertyIsEnumerable", [])
    
    Types::Object.set_global_prototype proto
    Types::Object.define_singleton_method(:constructor_function) { obj }
    scope.global_scope.root_object.prototype = proto
  end
end