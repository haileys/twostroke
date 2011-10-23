module Twostroke::Runtime
  class VM::Frame
    attr_reader :vm, :insns, :stack, :sp_stack, :ip, :scope
    
    def initialize(vm, section, callee = nil)
      @vm = vm
      @section = section
      @insns = vm.bytecode[section]
      @callee = callee
    end
    
    def execute(scope)
      @scope = scope || Scope.new(vm.global_scope)
      @stack = []
      @sp_stack = []
      @ip = 0
      @return = false
      
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
    
    def push(arg)
      if arg.is_a? Symbol
        stack.push scope.get_var arg
      elsif arg.is_a?(Fixnum) || arg.is_a?(Float) || arg.is_a?(String)
        stack.push arg
      else
        error! "bad argument to push instruction"
      end
    end
    
    def call(arg)
      args = []
      arg.times { args.unshift @stack.pop }
      fun = stack.pop
      error! "TypeError: called_non_callable" unless fun.is_a? Types::Function #@TODO
      stack.push fun.call(scope.global_scope, args)
    end
    
    def thiscall(arg)
      args = []
      arg.times { args.unshift stack.pop }
      fun = stack.pop
      unless fun.is_a? Types::Function #@TODO
        error! "TypeError: called_non_callable" 
      end
      stack.push fun.call(stack.pop, args)
    end
    
    def dup(arg)
      n = arg || 1
      stack.push *stack[-n..-1]
    end
    
    def member(arg)
      obj = Types.promote_primitive(stack.pop)
      error! "TypeError: non_object_property_load" unless obj.is_a?(Types::Object)
#      require 'pry'
#      pry binding
      stack.push obj.get(arg)
    end
    
    def set(arg)
      scope.set_var arg, stack.last
    end
    
    def ret(arg)
      @return = true
    end
    
    def eq(arg)
      ## javascript is fucked
      error! "== not implemented, please use === and convert types accordingly"
    end
    
    def seq(arg)
      b = Types.promote_primitive stack.pop
      a = Types.promote_primitive stack.pop
      if a.class != b.class
        stack.push false
      elsif a.is_a?(Types::String)
        stack.push(a.string == b.string)
      elsif a.is_a?(Types::Boolean)
        stack.push(a.boolean == b.boolean)
      elsif a.is_a?(Types::Number)
        if a.number.is_a?(Float) && a.number.nan?
          stack.push false
        elsif b.number.is_a?(Float) && b.number.nan?
          stack.push false
        else
          stack.push(a.number == b.number)
        end
      elsif a.is_a?(Types::Null) || a.nil?
        stack.push true
      else
        stack.push false
      end
    end
    
    def null(arg)
      stack.push Types::Null.null
    end
    
    def true(arg)
      stack.push true
    end
    
    def false(arg)
      stack.push false
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
      stack.push Types.is_falsy(stack.pop)
    end
    
    def inc(arg)
      stack.push Types.to_number(stack.pop) + 1
    end
    
    def dec(arg)
      stack.push Types.to_number(stack.pop) - 1
    end
    
    def pop(arg)
      stack.pop
    end
    
    def index(arg)
      index = Types.to_string stack.pop
      obj = Types.promote_primitive(stack.pop)
      error! "TypeError: non_object_property_load" unless obj.is_a?(Types::Object) #@TODO
      stack.push obj.get(index)
    end
    
    def array(arg)
      args = []
      arg.times { args.unshift stack.pop }
      stack.push Types::Array.new(args)
    end
    
    def undefined(arg)
      stack.push nil
    end
    
    def add(arg)
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
    end
    
    def sub(arg)
      right = Types.to_number(stack.pop)
      left = Types.to_number(stack.pop)
      stack.push left - right
    end
    
    def setindex(arg)
      val = stack.pop
      index = stack.pop
      obj = Types.promote_primitive(stack.pop)
      error! "TypeError: non_object_property_store" unless obj.is_a?(Types::Object) #@TODO
      obj.set index, val
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
      obj = stack.pop
      if obj.nil?
        stack.push "undefined"
      elsif obj.is_a?(Types::Function)
        stack.push "function"
      elsif obj.is_a?(Types::Object)
        stack.push "object"
      elsif obj.is_a?(Types::Null)
        stack.push "object" # wtf?
      elsif obj.is_a?(Float) || obj.is_a?(Fixnum)
        stack.push "number"
      elsif obj.is_a?(String)
        stack.push "string"
      else
        stack.push ""
      end
    end
    
    def close(arg)
      fun = Types::Function.new(->(this, args) { VM::Frame.new(vm, arg, fun).execute(scope.close) }, source: "TODO", name: "TODO")
      stack.push fun
    end
    
    def callee(arg)
      stack.push @callee
    end
    
    def object(arg)
      obj = Types::Object.new
      kvs = []
      arg.reverse_each { |a| kvs << [a, stack.pop] }
      kvs.reverse_each { |kv| obj.set kv[0], kv[1] }
      stack.push obj
    end
    
  private  
    def comparison_oper(op)
      right = Types.promote_primitive stack.pop
      left = Types.promote_primitive stack.pop
      
      if left.is_a?(Types::String) && right.is_a?(Types::String)
        stack.push left.string.send op, right.string
      else
        stack.push Types.to_number(left).send op, Types.to_number(right)
      end
    end
  
    def error!(msg)
      vm.send :error!, "#{msg} (at #{@section}+#{@ip - 1})"
    end
  end
end