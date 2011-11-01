module Twostroke::Runtime
  Lib.register do |scope|
    obj = Types::Object.new
    scope.set_var "Math", obj
    
    %w(sqrt).each do |method|
      obj.put method, Types::Function.new(->(scope, this, args) {
        Types::Number.new(Math.send method, Types.to_number(args[0] || Undefined.new).number)
      }, nil, method, [])
    end
  end
end