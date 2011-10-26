=begin
module Twostroke::Runtime
  Lib.register do |scope|
    ary = Types::Array.new.constructor
    scope.set_var "Array", ary
  end
end
=end