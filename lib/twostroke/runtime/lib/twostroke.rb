module Twostroke::Runtime
  Lib.register do |scope, vm|
    ts = Types::Object.new
    
    trace_handler = ->(trace_type, sc, this, args) {
      callback = args[0]
      Lib.throw_type_error "expected function" unless [Types::Function, Types::Null].include? callback.class
      if callback.is_a? Types::Null
        vm.send "#{trace_type}_trace=", nil
      else
        fn = ->(*a) {
          # traces are not re-entrant, so we need to remove it before calling
          # the trace function
          vm.send "#{trace_type}_trace=", nil
          # marshal data and call the trace function
          callback.call sc, nil, a.map(&Types.method(:marshal))
          # if the trace function hasn't set another trace function, restore it
          vm.send "#{trace_type}_trace=", fn unless vm.send "#{trace_type}_trace"
        }  
        vm.send "#{trace_type}_trace=", fn
      end
    }
    
    ts.put "setLineTrace", Types::Function.new(->(sc, this, args) {
      trace_handler.call :line, sc, this, args
    }, nil, "setLineTrace", ["callback"])
    
    ts.put "setInstructionTrace", Types::Function.new(->(sc, this, args) {
      trace_handler.call :instruction, sc, this, args
    }, nil, "setInstructionTrace", ["callback"])
    
    ts.put "addOperator", Types::Function.new(->(sc, this, args) {
      oper = Types.to_string(args[0] || Types::Undefined.new).string
      fn = args[1]
      Lib.throw_type_error "expected function" unless fn.respond_to? :call
      Twostroke::Lexer::TOKENS.unshift [ :USER_OP, Regexp.new("\\A#{Regexp.escape oper}", Regexp::MULTILINE), ->m { m[0] } ]
      vm.user_operators[oper] = fn
    }, nil, "addOperator", ["operator", "fn"])
    
    scope.set_var "Twostroke", ts
  end
end