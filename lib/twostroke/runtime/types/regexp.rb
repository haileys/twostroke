module Twostroke::Runtime::Types
  class RegExp < Object
    def self.constructor_function
      @@constructor_function ||=
        Function.new(->(scope, this, args) {
          RegExp.new((args[0] && !args[0].is_a?(Undefined)) ? Twostroke::Runtime::Types.to_string(args[0]).string : "", args[1] && Twostroke::Runtime::Types.to_string(args[1]).string)
        }, nil, "RegExp", [])
    end
    
    attr_reader :regexp
    attr_reader :global
    def initialize(regexp_source, options)
      opts = 0
      (options ||= "").each_char do |opt|
        opts |= case opt
        when "m"; Regexp::MULTILINE
        when "i"; Regexp::IGNORECASE
        else; 0
        end
      end
      @regexp = Regexp.new regexp_source, opts
      @global = options.include? "g"
      @prototype = RegExp.constructor_function.get("prototype")
      super()
    end
    
    def primitive_value
      String.new(regexp.inspect + (@global ? "g" : ""))
    end
  end
end