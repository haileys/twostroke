module Twostroke::Runtime
  Lib.register do |scope|
    str = Types::String.new("").constructor
    scope.set_var "String", str
    
    str.set "fromCharCode", Types::Function.new(->(this, args) {
      args.map { |a| Types.to_number(a).to_i.chr }.join
    })
  end
end