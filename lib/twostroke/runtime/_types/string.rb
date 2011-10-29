module Twostroke::Runtime::Types
  class String < Object
    attr_accessor :string
    
    def initialize(string)
      @string = string
      super()
    end
    
    def constructor
      unless defined?(@@constructor)
        @@constructor = Function.new nil, name: "String" do |this, args|
          String.new Types.to_string(args[0])
        end
        proto = Object.new
        proto.set("charCodeAt", Function.new(->(this, args) { this[args[0].to_i].ord }))
        proto.properties["length"] = {
          getter: ->(this) { this.string.size }
        }
        # more to come...
        @@constructor.set "prototype", proto
      end
      @@constructor
    end
    
    def to_boolean
      string != ""
    end
    
    def to_number
      string =~ /\.e/i ? string.to_i : string.to_f
    end
    
    def to_string
      string
    end
    
    def get(prop)
      prop = prop.to_s
      if prop =~ /\A\d+\z/
        string[prop.to_i]
      else
        super prop
      end
    end
  end
end