module Twostroke::Runtime::Types
  class Boolean < Object
    attr_accessor :boolean
    
    def initialize(boolean)
      @boolean = boolean
      super()
    end
    
    def constructor
      unless defined?(@@constructor)
        @@constructor = Function.new nil, name: "Boolean" do |this, *args|
          Boolean.new Types.to_boolean(args[0])
        end
        proto = Object.new
        @@constructor.set "prototype", proto
      end
      @@constructor
    end
    
    def to_boolean
      boolean
    end
    
    def to_number
      boolean ? 1 : 0
    end
    
    def to_string
      boolean.to_s
    end
  end
end