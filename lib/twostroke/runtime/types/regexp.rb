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
      @regexp = Regexp.new RegExp.to_ruby_regexp(regexp_source), opts
      @global = options.include? "g"
      @prototype = RegExp.constructor_function.get("prototype")
      super()
    end
    
    def to_ruby
      regexp
    end
    
    def self.to_ruby_regexp(src)
      src.
      
      # javascript's ^$ match the start and end of the entire string
      # ruby's ^$ are line-based, so convert to \A and \z
        gsub(/([^\[]|\A)\^/,"\\1\\A").gsub(/((\]|\A)([^\[]*))\$/,"\\1\\z").
      
      # javascript supports \cA through \cZ for control characters
        gsub(/\\c[a-z]/i) { |m| (m.last.downcase.ord - 'a'.ord).chr }
    end
    
    def self.exec(scope, this, args)
      re = this.is_a?(RegExp) ? this : constructor_function.(nil, nil, this)
      str = Twostroke::Runtime::Types.to_string(args[0] || Twostroke::Runtime::Types::Undefined.new).string
      idx = re.global ? Twostroke::Runtime::Types.to_uint32(re.get("lastIndex")) : 0
      if md = re.regexp.match(str, idx)
        result = Twostroke::Runtime::Types::Array.new md.to_a.map { |s| s ? Twostroke::Runtime::Types::String.new(s) : Twostroke::Runtime::Types::Undefined.new }
        result.put "index", Twostroke::Runtime::Types::Number.new(md.offset(0).first)
        result.put "input", Twostroke::Runtime::Types::String.new(str)
        re.put "lastIndex", Twostroke::Runtime::Types::Number.new(md.offset(0).last)
        result
      else
        Twostroke::Runtime::Types::Null.new
      end
    end
    
    def self.all_matches(scope, this, args)
      re = this.is_a?(RegExp) ? this : constructor_function.(nil, nil, this)
      str = Twostroke::Runtime::Types.to_string(args[0] || Twostroke::Runtime::Types::Undefined.new).string
      arr = []
      idx = 0
      while md = re.regexp.match(str, idx)
        arr << Twostroke::Runtime::Types::String.new(md[0])
        idx = md.offset(0).last
      end
      if arr.any?
        result = Twostroke::Runtime::Types::Array.new arr
        result.put "index", Twostroke::Runtime::Types::Number.new(re.regexp.match(str).offset(0).first)
        result.put "input", Twostroke::Runtime::Types::String.new(str)
        result
      else
        Twostroke::Runtime::Types::Null.new
      end
    end
  end
end