module Twostroke::Runtime
  Lib.register do |scope|
    obj = Types::Object.new
    scope.set_var "Math", obj
    
    scope.set_var "Infinity", Types::Number.new(Float::INFINITY)
    scope.set_var "NaN", Types::Number.new(Float::NAN)
    
    scope.set_var "isNaN", Types::Function.new(->(scope, this, args) {
      Types::Boolean.new(args[0].is_a?(Types::Number) && args[0].nan?)
    }, nil, "isNaN", [])
    
    # one argument functions
    %w(sqrt sin cos tan).each do |method|
      obj.proto_put method, Types::Function.new(->(scope, this, args) {
          Types::Number.new(Math.send method, Types.to_number(args[0] || Undefined.new).number)
        }, nil, method, [])
    end

    obj.proto_put "random", Types::Function.new(->(scope, this, args) {
      Types::Number.new rand
    }, nil, "random", [])

    obj.proto_put "floor", Types::Function.new(->(scope, this, args) {
        Types::Number.new Types.to_number(args[0] || Undefined.new).number.floor
      }, nil, "floor", [])

    obj.proto_put "ceil", Types::Function.new(->(scope, this, args) {
        Types::Number.new Types.to_number(args[0] || Undefined.new).number.ceil
      }, nil, "ceil", [])
    
    obj.proto_put "max", Types::Function.new(->(scope, this, args) {
        Types::Number.new [-Float::INFINITY, *args.map { |a| Types.to_number(a).number }].max
      }, nil, "max", [])
    
    obj.proto_put "min", Types::Function.new(->(scope, this, args) {
        Types::Number.new [Float::INFINITY, *args.map { |a| Types.to_number(a).number }].min
      }, nil, "min", [])
  end
end