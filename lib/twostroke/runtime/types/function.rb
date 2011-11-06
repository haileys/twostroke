module Twostroke::Runtime::Types
  class Function < Object
    def self.constructor_function
      unless defined?(@@constructor_function)
        @@constructor_function = Function.new(->(scope, this, args) { raise "@TODO" }, nil, "Function", [])
        @@constructor_function._class = @@constructor_function
      end
      @@constructor_function
    end
    
    attr_reader :arguments, :name, :source, :function
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
      put "prototype", Object.new
    end
    
    def prototype
      @prototype ||= Function.constructor_function.get("prototype")
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
      retn_val = function.(upper_scope, this, args)
      # prevent non-Value objects being returned to javascript
      if retn_val.is_a? Value
        retn_val
      else
        Undefined.new
      end
    end
  end
end