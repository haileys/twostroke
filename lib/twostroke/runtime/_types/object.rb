module Twostroke::Runtime::Types
  class Object
    attr_accessor :prototype, :fields, :properties
    
    def initialize
      @properties = {}
      @fields = {}
      @prototype = constructor && constructor.get("prototype")
    end
    
    def has_own_prop(prop)
      prop = prop.to_s
      properties.has_key?(prop) || fields.has_key?(prop)
    end
    
    def get(prop, this = self)
      prop = prop.to_s
      if properties.has_key? prop
        properties[prop][:getter].call(this)
      elsif fields.has_key? prop
        fields[prop]
      else
        prototype && prototype.get(prop, this)
      end
    end
    
    def set(prop, val, this = self)
      prop = prop.to_s
      if properties.has_key? prop
        properties[prop][:setter].call(this, val)
      elsif fields.has_key? prop
        fields[prop] = val
      elsif prototype
        prototype.set(prop, val, this)
      else
        fields[prop] = val
      end
    end
    
    def constructor
      if caller.size > 10
        puts caller
        require 'pry'
        pry binding
      end
      unless defined?(@@constructor)
        @@constructor = Function.new nil, name: "Object" do |this, args|
          Object.new Types.to_string(args[0])
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
    
    def to_s
      "{ #{fields.map { |k,v| "'#{k}': #{v}" }.join ", " } }"
    end
  end
end