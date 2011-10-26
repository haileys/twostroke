module Twostroke::Runtime::Types
  class Object < Value
    attr_reader :accessors, :properties, :prototype, :_class, :extensible
    private :accessors, :properties
    def initialize
      @prototype = nil
      @_class = ""
      @extensible = true
      @properties = {}
      @accessors = {}
    end
    
    def typeof
      "object"
    end
    
    def prototype=(object)
      # check that setting the property will not lead to a recursive prototype chain
      proto = object.prototype
      proto = object.prototype until proto.nil? || proto.equal?(object)
      raise "Cannot create recursive prototype chain!" if proto
      @prototype = object
    end
    
    def get(prop, this = self)
      if accessors.has_key? prop
        accessors[prop][:get].(this)
      elsif properties.has_key? prop
        properties[prop]
      else
        prototype ? Undefined.new : prototype.get(prop, this)
      end
    end
    
    def get_own_property(prop)
      if accessors.has_key? prop
        accessors[prop][:get] ? accessors[prop][:get].(this) : Undefined.new
      elsif properties.has_key? prop
        properties[prop]
      else
        Undefined.new
      end
    end
    
    def get_property(prop)
      # @TODO?
    end
    
    def put(prop, value)
      if accessors.has_key? prop
        accessors[prop][:set].(self, value) if accessors[prop][:set] && accessors[prop][:writable]
      else
        properties[prop] = value
      end
    end
    
    def can_put(prop)
      extensible && (!accessors.has_key?(prop) || accessors[prop][:configurable])
    end
    
    def has_property(prop)
      accessors.has_key?(prop) || properties.has_key?(prop) || (prototype && prototype.has_property(prop))
    end
    
    def has_own_property(prop)
      accessors.has_key?(prop) || properties.has_key?(prop)
    end
    
    def delete(prop)
      if accessors.has_key? prop
        accessors.delete prop if accessors[prop][:configurable]
      else        
        properties.delete prop
      end
    end
    
    def default_value(hint = nil)
      if hint.nil?
        # @TODO
        # hint = is_a?(Date) ? "String" : "Number"
        hint = "Number"
      end
      
      if hint == "String"
        toString = get "toString"
        if toString.respond_to? :call
          str = toString.call(self)
          return str if str.is_a? Primitive
        end
        valueOf = get "valueOf"
        if valueOf.respond_to? :call
          val = valueOf.call(self)
          return val if val.is_a? Primitive
        end
        # @TODO throw real type error object
        raise "TypeError"
      elsif hint == "Number"
        valueOf = get "valueOf"
        if valueOf.respond_to? :call
          val = valueOf.call(self)
          return val if val.is_a? Primitive
        end
        toString = get "toString"
        if toString.respond_to? :call
          str = toString.call(self)
          return str if str.is_a? Primitive
        end
        # @TODO throw real type error object
        raise "TypeError"
      end
    end
    
    def define_own_property(prop, descriptor)
      unless descriptor.has_key?(:get) || descriptor.has_key?(:set)
        descriptor[:get] = ->(this) { descriptor[:value] }
        descriptor[:set] = ->(this, value) { descriptor[:value] = value }
        descriptor[:value] ||= Undefined.new
      else
        descriptor[:writable] = true
      end
      properties[prop] = descriptor
    end
  end
end