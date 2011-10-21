module Twostroke::Runtime::Types
  class String < Object
    attr_accessor :string
    
    def initialize(string)
      @string = string
      super
    end
    
    def typeof
      "string"
    end
    
    def to_s
      string
    end
    
    def constructor
      unless @@constructor
        @@constructor ||= Function.new nil, name: "String" do |this, *args|
          String.new args[0].to_s
        end
        proto = Object.new
        proto.set("charCodeAt", Function.new(->(this, *args) { this[args[0].to_i] }))
        # more to come...
        @@constructor.prototype = proto
      end
      @@constructor
    end
  end
end