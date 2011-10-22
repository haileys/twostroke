module Twostroke::Runtime
  class VM::Frame
    attr_reader :vm, :insns, :stack, :sp_stack, :ip, :scope
    
    def initialize(vm, section)
      @vm = vm
      @insns = vm.bytecode[section]
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
      fun.call(scope.global_scope, args)
    end
    
    def thiscall(arg)
      args = []
      arg.times { args.unshift stack.pop }
      fun = stack.pop
      error! "TypeError: called_non_callable" unless fun.is_a? Types::Function #@TODO
      fun.call(stack.pop, args)
    end
    
    def dup(arg)
      stack.push stack.last
    end
    
    def member(arg)
      stack.push Types.promote_primitive(stack.pop).get(arg)
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
    
  private
    def error!(msg)
      vm.send :error!, msg
    end
  end
end