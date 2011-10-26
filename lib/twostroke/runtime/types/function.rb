module Twostroke::Runtime::Types
  class Function < Object
    def self.constructor_function
      # @TODO
    end
    
    attr_reader :arguments, :name, :source, :function
    def initialize(function, source, name, arguments)
      @function = function
      @source = source
      @name = name
      @arguments = arguments
      super()
    end
    
    def primitive_value
      String.new "function #{name}(#{arguments.join ","}) { #{source || "[native code]"} }"
    end
    
    def call(this, args)
      retn_val = function.(this, args)
      # prevent non-Value objects being returned to javascript
      if retn_val.is_a? Value
        retn_val
      else
        Undefined.new
      end
    end
  end
end