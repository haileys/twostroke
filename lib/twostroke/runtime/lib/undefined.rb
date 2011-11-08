module Twostroke::Runtime
  Lib.register do |scope|
    scope.set_var "undefined", Types::Undefined.new
    
    scope.set_var "crap", Types::Function.new(->(scope,this,args) { require "pry"; pry binding }, nil, "crap", [])
  end
end