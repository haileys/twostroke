module Twostroke::Runtime
  class VM
    attr_accessor :bytecode
    attr_reader :global_scope
    
    def initialize(bytecode)
      @bytecode = bytecode
      @global_scope = GlobalScope.new
    end
    
    def execute(section = :main, scope = nil)
      scope ||= Scope.new @global_scope
      stack = []
      sp_stack = []
      
      bytecode[section].each do |op|
        ins, arg = *op
        if ins[0] == "." # directive
          case ins
          when :".local"
            scope.declare arg.intern
          else
            error! "unknown directive #{ins}"
          end
        else
          handler = INSTRUCTIONS[ins] || error!("unknown instruction #{ins}")
          handler.(arg, scope, stack, sp_stack)
        end
      end
    end
  
  private
    def error!(msg)
      VM.error! msg
    end
    def self.error!(msg)
      raise RuntimeError, msg
    end
    def self.promote_primitive(obj)
      if obj.respond_to? :typeof # not a primitive
        obj
      elsif obj.is_a? String
        Types::String.new obj
      elsif obj.nil? || obj.is_a?(Types::Null)
        error! "TypeError: non_object_property_load" #@TODO
      else
        error! "unknown primitive type #{obj.class} (#{obj})"
      end
    end
  
    INSTRUCTIONS = {
      push: ->(arg, scope, stack, sp_stack) do
        if arg.is_a? Symbol
          stack.push scope.get_var arg
        elsif arg.is_a?(Fixnum) || arg.is_a?(Float) || arg.is_a?(String)
          stack.push arg
        else
          error! "bad argument to push instruction"
        end
      end,
      call: ->(arg, scope, stack, sp_stack) do
        args = []
        arg.times { args.unshift stack.pop }
        fun = stack.pop
        error! "TypeError: called_non_callable" unless fun.is_a? Types::Function #@TODO
        fun.call(scope.global_scope, args)
      end,
      thiscall: ->(arg, scope, stack, sp_stack) do
        args = []
        arg.times { args.unshift stack.pop }
        fun = stack.pop
        error! "TypeError: called_non_callable" unless fun.is_a? Types::Function #@TODO
        fun.call(stack.pop, args)
      end,
      dup: ->(arg, scope, stack, sp_stack) do
        stack.push stack.last
      end,
      member: ->(arg, scope, stack, sp_stack) do
        obj = promote_primitive stack.pop
        stack.push obj.get(arg)
      end
    }
  end
end