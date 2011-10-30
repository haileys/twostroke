module Twostroke::Runtime
  Lib.register do |scope|
    proto = Types::Object.new
  
    obj = Types::Function.new(->(scope, this, args) { args.length.zero? ? Types::Object.new : Types.to_object(args[0]) }, nil, "Object", [])
    obj.prototype = proto
    obj.put "prototype", proto
    scope.set_var "Object", obj
    
    proto.put "toString", Types::Function.new(->(scope, this, args) { Types::String.new "[object #{this._class || "Object"}]" }, nil, "toString", [])
    
    Types::Object.set_global_prototype proto
=begin
    obj = Types::Object.constructor_function
    proto = Types::Object.new(true)
    proto.put "toString", Types::Function.new(->(scope, this, args) { Types::String.new "[object #{this._class || "Object"}]" }, nil, "toString", [])
    obj.put "prototype", proto
    obj.prototype = proto
    scope.set_var "Object", obj
=end
  end
end