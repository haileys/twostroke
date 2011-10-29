module Twostroke::Runtime::Types
  class Function < Object
    def self.constructor_function
      @@constructor_function ||=
        Function.new(->(scope, this, args) { raise "@TODO" }, nil, "Function", [])
    end
    
    def prototype
      @prototype ||= Function.constructor_function.get("prototype")
    end
    
    attr_reader :arguments, :name, :source, :function
    def initialize(function, source, name, arguments)
      @function = function
      @source = source
      @name = name
      @arguments = arguments
      super()
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