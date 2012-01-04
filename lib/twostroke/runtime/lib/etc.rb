module Twostroke::Runtime
  Lib.register do |scope|
    evaled = 0
    scope.set_var "eval", Types::Function.new(->(_scope, this, args) {
        begin
          parser = Twostroke::Parser.new(Twostroke::Lexer.new(Types.to_string(args[0] || Types::Undefined.new).string + ";"))
          parser.parse
        rescue Twostroke::SyntaxError => e  
          Lib.throw_syntax_error e.to_s
        end

        evaled += 1
        compiler = Twostroke::Compiler::TSASM.new parser.statements, "evaled_#{evaled}_"
        puts "HI"
        compiler.compile
        
        vm = scope.global_scope.vm
        compiler.bytecode.each do |k,v|
          vm.bytecode[k] = v
        end
        
        vm.bytecode[:"evaled_#{evaled}_main"][-2] = [:ret]
        vm.execute :"evaled_#{evaled}_main", _scope
      }, nil, "eval", [])
  end
end