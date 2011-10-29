module Twostroke::Runtime
  Lib.register do |scope|
    scope.set_var "undefined", Types::Undefined.new
  end
end