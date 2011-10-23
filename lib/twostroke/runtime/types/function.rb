module Twostroke::Runtime::Types
  class Function < Object
    attr_accessor :function, :source, :name
    
    def initialize(function, opts = {}, &bk)
      @function = function || bk
      @source = opts[:source] || "[native code]"
      @name = opts[:name]
      super()
    end
    
    def call(this, *args)
      function.call(this, *args)
    end

=begin    
    def to_s
      "function #{name}() { #{source} }"
    end
=end
  end
end