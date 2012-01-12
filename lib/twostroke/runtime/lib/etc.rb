module Twostroke::Runtime
  Lib.register do |scope|
    evaled = 0
    eval = Types::Function.new(->(_scope, this, args) {      
        src = Types.to_string(args[0] || Types::Undefined.new).string + ";"
        begin
          scope.global_scope.vm.eval src, _scope, this
        rescue Twostroke::SyntaxError => e
          Lib.throw_syntax_error e.to_s
        end
      }, nil, "eval", [])
    eval.inherits_caller_this = true
    scope.set_var "eval", eval
  end
end