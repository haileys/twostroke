module Twostroke::Runtime
  Lib.register do |scope|
    obj = Types::Object.new
    scope.set_var "Math", obj
    
    scope.set_var "Infinity", Types::Number.new(Float::INFINITY)
    
    # one argument functions
    %w(sqrt sin cos tan).each do |method|
      obj.put method, Types::Function.new(->(scope, this, args) {
          Types::Number.new(Math.send method, Types.to_number(args[0] || Undefined.new).number)
        }, nil, method, [])
    end

    obj.put "random", Types::Function.new(->(scope, this, args) {
      Types::Number.new rand
    }, nil, "random", [])

    obj.put "floor", Types::Function.new(->(scope, this, args) {
        Types::Number.new Types.to_number(args[0] || Undefined.new).number.floor
      }, nil, "floor", [])

    obj.put "ceil", Types::Function.new(->(scope, this, args) {
        Types::Number.new Types.to_number(args[0] || Undefined.new).number.ceil
      }, nil, "ceil", [])
    
    obj.put "max", Types::Function.new(->(scope, this, args) {
        Types::Number.new [-Float::INFINITY, *args.map { |a| Types.to_number(a).number }].max
      }, nil, "max", [])
    
    obj.put "min", Types::Function.new(->(scope, this, args) {
        Types::Number.new [Float::INFINITY, *args.map { |a| Types.to_number(a).number }].min
      }, nil, "min", [])
  end
end