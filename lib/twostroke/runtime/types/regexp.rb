module Twostroke::Runtime::Types
  class RegExp < Object
    def self.constructor_function
      @@constructor_function ||=
        Function.new(->(scope, this, args) {
          RegExp.new Regexp.new(Twostroke::Runtime::Types.to_string(args[0] || Undefined.new).string, args[1] && Twostroke::Runtime::Types.to_string(args[1]).string)
        }, nil, "RegExp", [])
    end
    
    attr_reader :regexp
    def initialize(regexp)
      @regexp = regexp
      @prototype = RegExp.constructor_function.get("prototype")
      super()
    end
    
    def primitive_value
      String.new regexp.inspect
    end
  end
end