module Twostroke::Runtime
  class VM::Frame
    attr_reader :vm, :insns, :stack, :sp_stack, :ip, :scope
    
    def initialize(vm, section, callee = nil)
      @vm = vm
      @section = section
      @insns = vm.bytecode[section]
      @callee = callee
    end
    
    def execute(scope, this = nil)
      @scope = scope || Scope.new(vm.global_scope)
      @stack = []
      @sp_stack = []
      @ip = 0
      @return = false
      @this = this || @scope.global_scope.root_object
      
      until @return
        ins, arg = *insns[ip]
        @ip += 1
        if respond_to? ins
          public_send ins, arg
        else
          error! "unknown instruction #{ins}"
        end
      end
      
      stack.last
    end
    
    define_method ".local" do |arg|
      scope.declare arg.intern
    end
    
    ## instructions
    
    def push(arg)
      if arg.is_a? Symbol
        stack.push scope.get_var(arg)
      elsif arg.is_a?(Fixnum) || arg.is_a?(Float)
        stack.push Types::Number.new(arg)
      elsif arg.is_a?(String)
        stack.push Types::String.new(arg)
      else
        error! "bad argument to push instruction"
      end
    end
    
    def call(arg)
      args = []
      arg.times { args.unshift @stack.pop }
      fun = stack.pop
      error! "TypeError: called_non_callable" unless fun.respond_to?(:call) #@TODO
      stack.push fun.call(scope, scope.global_scope.root_object, args)
    end
    
    def thiscall(arg)
      args = []
      arg.times { args.unshift stack.pop }
      fun = stack.pop
      error! "TypeError: called_non_callable" unless fun.respond_to?(:call) #@TODO
      stack.push fun.call(scope, Types.to_object(stack.pop), args)
    end
    
    def newcall(arg)
      args = []
      arg.times { args.unshift @stack.pop }
      fun = stack.pop
      error! "TypeError: called_non_callable" unless fun.respond_to?(:call) #@TODO
      obj = Types::Object.new
      obj.construct prototype: fun.get("prototype"), _class: fun.name do
        retn = fun.call(scope, obj, args)
        if retn.is_a?(Types::Undefined)
          stack.push obj
        else
          stack.push retn
        end
      end
    end
    
    def dup(arg)
      n = arg || 1
      stack.push *stack[-n..-1]
    end
    
    def member(arg)
      stack.push Types.to_object(stack.pop).get(arg.to_s)
    end
    
    def set(arg)
      scope.set_var arg, stack.last
    end
    
    def setprop(arg)
      val = stack.pop
      obj = stack.pop
      obj.put arg.to_s, val
      stack.push val
    end
    
    def ret(arg)
      @return = true
    end
    
    def eq(arg)
      ## javascript is fucked
      error! "== not yet implemented, please use === and convert types accordingly"
    end
    
    def seq(arg)
      if a.class == b.class
        a === b
      else
        # @TODO: coerce
        raise "@TODO"
      end
    end
    
    def null(arg)
      stack.push Types::Null.new
    end
    
    def true(arg)
      stack.push Types::Boolean.new(true)
    end
    
    def false(arg)
      stack.push Types::Boolean.new(false)
    end
    
    def jmp(arg)
      @ip = arg.to_i
    end
    
    def jif(arg)
      if Types.is_falsy stack.pop
        @ip = arg.to_i
      end
    end
    
    def jit(arg)
      if Types.is_truthy stack.pop
        @ip = arg.to_i
      end
    end
    
    def not(arg)
      stack.push Types::Boolean.new(Types.is_falsy(stack.pop))
    end
    
    def inc(arg)
      stack.push Types::Number.new(Types.to_number(stack.pop).number + 1)
    end
    
    def dec(arg)
      stack.push Types::Number.new(Types.to_number(stack.pop).number - 1)
    end
    
    def pop(arg)
      stack.pop
    end
    
    def index(arg)
      index = Types.to_string(stack.pop).string
      stack.push Types.to_object(stack.pop).get(index)
    end
    
    def array(arg)
      args = []
      arg.times { args.unshift stack.pop }
      stack.push Types::Array.new(args)
    end
    
    def undefined(arg)
      stack.push Types::Undefined.new
    end
    
    def add(arg)
      #@TODO
=begin
      right = Types.promote_primitive stack.pop
      left = Types.promote_primitive stack.pop
      if left.is_a?(Types::Number) && right.is_a?(Types::Number)
        stack.push left.number + right.number
      elsif left.is_a?(Types::Null) && right.is_a?(Types::Number)
        stack.push right.number
      elsif left.nil? && right.is_a?(Types::Number)
        stack.push Float::NAN
      elsif right.is_a?(Types::Null) && left.is_a?(Types::Number)
        stack.push left.number
      elsif right.nil? && left.is_a?(Types::Number)
        stack.push Float::NAN
      else
        stack.push Types.to_string(left) + Types.to_string(right)
      end
=end
    end
    
    def sub(arg)
      right = Types.to_number(stack.pop).number
      left = Types.to_number(stack.pop).number
      stack.push Types::Number.new(left - right)
    end
    
    def setindex(arg)
      val = stack.pop
      index = Types.to_string(stack.pop).string
      Types.to_object(stack.pop).put index, val
      stack.push val
    end
    
    def lt(arg)
      comparison_oper :<
    end
    
    def lte(arg)
      comparison_oper :<=
    end
    
    def gt(arg)
      comparison_oper :>
    end
    
    def gte(arg)
      comparison_oper :>=
    end
    
    def typeof(arg)
      stack.push Types::String.new(stack.pop.typeof)
    end
    
    def close(arg)
      arguments = vm.bytecode[arg].take_while { |ins,arg| ins == :".arg" }.map(&:last).map(&:to_s)
      fun = Types::Function.new(->(outer_scope, this, args) { VM::Frame.new(vm, arg, fun).execute(scope.close, this) }, "source @TODO", "name @TODO", arguments)
      stack.push fun
    end
    
    def callee(arg)
      stack.push @callee
    end
    
    def object(arg)
      obj = Types::Object.new
      kvs = []
      arg.reverse_each { |a| kvs << [a, stack.pop] }
      kvs.reverse_each { |kv| obj.put kv[0].to_s, kv[1] }
      stack.push obj
    end
    
    def negate(arg)
      Types::Number.new(-Types.to_number(stack.pop).number)
    end
    
    def pushsp(arg)
      sp_stack.push stack.size
    end
    
    def popsp(arg)
      @stack = stack[0...sp_stack.pop]
    end
    
    def this(arg)
      stack.push @this
    end
    
  private
    def comparison_oper(op)
=begin
      right = Types.promote_primitive stack.pop
      left = Types.promote_primitive stack.pop
      
      if left.is_a?(Types::String) && right.is_a?(Types::String)
        stack.push left.string.send op, right.string
      else
        stack.push Types.to_number(left).send op, Types.to_number(right)
      end
=end
      #@TODO
    end
  
    def error!(msg)
      vm.send :error!, "#{msg} (at #{@section}+#{@ip - 1})"
    end
  end
end