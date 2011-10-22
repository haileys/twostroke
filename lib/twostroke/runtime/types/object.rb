module Twostroke::Runtime::Types
  class Object
    attr_accessor :constructor, :prototype, :fields, :properties
    
    def initialize
      @properties = {}
      @fields = {}
      @prototype = constructor && constructor.get("prototype")
    end
    
    def has_own_prop(prop)
      prop = prop.to_s
      properties.has_key?(prop) || fields.has_key?(prop)
    end
    
    def get(prop)
      prop = prop.to_s
      if properties.has_key? prop
        properties[prop][:getter].call(properties[prop])
      elsif fields.has_key? prop
        fields[prop]
      else
        prototype && prototype.get(prop)
      end
    end
    
    def set(prop, val)
      prop = prop.to_s
      if properties.has_key? prop
        properties[prop][:setter].call(properties[prop], val)
      elsif fields.has_key? prop
        fields[prop] = val
      elsif prototype
        prototype.set(prop, val)
      else
        fields[prop] = val
      end
    end
  end
end