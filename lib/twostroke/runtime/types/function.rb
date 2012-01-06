module Twostroke::Runtime::Types
  class Function < Object
    def self.constructor_function
      unless defined?(@@constructor_function)
        @@constructor_function = nil # lock the Function constructor out from here...
        @@created_funcs = 0
        @@constructor_function = Function.new(->(scope, this, args) {
          formal_parameters = (args.size > 1 ? args[0...-1] : []).map { |a| Twostroke::Runtime::Types.to_string(a).string }
          src = Twostroke::Runtime::Types.to_string(args[-1] || Undefined.new).string
          
          parser = Twostroke::Parser.new(Twostroke::Lexer.new(src))
          parser.parse

          @@created_funcs += 1
          fun_ast = Twostroke::AST::Function.new name: "anonymous", arguments: formal_parameters, statements: parser.statements
          compiler = Twostroke::Compiler::TSASM.new [fun_ast], "runtime_created_#{@@created_funcs}_"
          compiler.compile
          
          vm = scope.global_scope.vm
          compiler.bytecode.each do |k,v|
            vm.bytecode[k] = v
          end
          
          global_scope = vm.global_scope
          fun = Function.new(->(_scope, _this, _args) {
            Twostroke::Runtime::VM::Frame.new(vm, :"runtime_created_#{@@created_funcs}_fn_1", fun).execute(global_scope, _this, _args)
          }, src, "anonymous", formal_parameters)
        }, nil, "Function", [])
        @@constructor_function.proto_put "constructor", @@constructor_function
        @@constructor_function._class = @@constructor_function
      end
      @@constructor_function
    end
    
    attr_reader :arguments, :name, :source, :function
    attr_accessor :inherits_caller_this
    def initialize(function, source, name, arguments)
      @function = function
      @source = source
      @name = name
      @arguments = arguments
      # setting @_class to Function's constructor would result in a stack overflow,
      # so we'll set it to nil and patch things up after @@constructor_function has
      # been set
      @_class = nil unless defined?(@@constructor_function)
      super()
      @prototype = nil
      proto = Object.new
      proto.construct _class: self
      put "prototype", proto
    end
    
    def prototype
      @prototype ||= Function.constructor_function.get("prototype") if Function.constructor_function
    end
    
    def has_instance(obj)
      return false unless obj.is_a? Object
      o = get "prototype"
      Twostroke::Runtime::Lib.throw_type_error "Function prototype not an object" unless o.is_a? Object
      loop do
        obj = obj.prototype
        return false unless obj.is_a?(Object)
        return true if obj == o
      end
    end
    
    def typeof
      "function"
    end
    
    def primitive_value
      String.new "function #{name}(#{arguments.join ","}) { #{source || "[native code]"} }"
    end
    
    def call(upper_scope, this, args)
      retn_val = function.(upper_scope, this || upper_scope.global_scope.root_object, args)
      # prevent non-Value objects being returned to javascript
      if retn_val.is_a? Value
        retn_val
      else
        Undefined.new
      end
    end
  end
end