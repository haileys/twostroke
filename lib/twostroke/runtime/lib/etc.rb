module Twostroke::Runtime
  Lib.register do |scope|
    evaled = 0
    eval = Types::Function.new(->(_scope, this, args) {      
        src = Types.to_string(args[0] || Types::Undefined.new).string + ";"
        
        begin
          parser = Twostroke::Parser.new Twostroke::Lexer.new src
          parser.parse

          evaled += 1
          compiler = Twostroke::Compiler::TSASM.new parser.statements, "evaled_#{evaled}_"
          compiler.compile
        rescue Twostroke::SyntaxError => e
          Lib.throw_syntax_error e.to_s
        end
        
        vm = scope.global_scope.vm
        compiler.bytecode.each do |k,v|
          vm.bytecode[k] = v
        end
        
        vm.bytecode[:"evaled_#{evaled}_main"][-2] = [:ret]
        vm.execute :"evaled_#{evaled}_main", _scope, this
      }, nil, "eval", [])
    eval.inherits_caller_this = true
    scope.set_var "eval", eval
  end
end