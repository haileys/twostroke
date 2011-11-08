module Twostroke::Runtime::Types
  class Object < Value
    attr_accessor :_class
    attr_reader :accessors, :properties, :prototype, :extensible
    private :accessors, :properties

    def initialize
      @extensible = true
      @properties = {}
      @accessors = {}
      @prototype ||= defined?(@@_prototype) ? @@_prototype : Null.new
      @_class = self.class.constructor_function if !defined?(@_class) && self.class.respond_to?(:constructor_function)
      proto_put "constructor", @_class
    end
    
    def _class=(c)
      put "constructor", (@_class = c)
    end
    
    def self.set_global_prototype(proto)
      @@_prototype = proto
    end
    
    def typeof
      "object"
    end
    
    def prototype=(object)
      @prototype = object
    end
    
    def constructing?
      @constructing
    end
    
    # this allows us to treat the object like a generic array.
    # the value of this method is not memoized, so call sparingly
    def generic_items
      return items if respond_to? :items
      len = Twostroke::Runtime::Types.to_number(get "length").number
      return [] if (len.is_a?(Float) && (len.nan? || len.infinite?)) || len < 0
      len = len.to_i
      (0...len).map { |i| get i.to_s }
    end
    
    def construct(opts = {})
      @constructing = true
      opts.each do |k,v|
        if respond_to? "#{k}="
          send "#{k}=", v
        else
          instance_variable_set "@#{k}", v
        end
      end
      yield
      @constructing = false
    end
    
    def get(prop, this = self)
      if accessors.has_key? prop
        accessors[prop][:get].(this)
      elsif properties.has_key? prop
        properties[prop]
      else
        prototype && prototype.is_a?(Object) ? prototype.get(prop, this) : Undefined.new
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
    
    def each_enumerable_property(&bk)
      accessors.select { |k,v| v[:enumerable] }.each { |k,v| yield k }
      properties.reject { |k,v| accessors[k] }.each { |k,v| yield k }
      if prototype && prototype.is_a?(Object)
        prototype.each_enumerable_property &bk
      end
    end
    
    def put(prop, value, this = self)
      if accessors.has_key? prop
        accessors[prop][:set].(this, value) if accessors[prop][:set] && accessors[prop][:writable]
      elsif properties.has_key? prop
        properties[prop] = value
      #elsif prototype && prototype.is_a?(Object) && prototype.has_accessor(prop)
      #  prototype.put prop, value, this
      else
        properties[prop] = value
      end
    end
    
    # puts prop as a non-enumerable property
    def proto_put(prop, value)
      define_own_property prop, value: value, enumerable: false
    end
    
    def can_put(prop)
      extensible && (!accessors.has_key?(prop) || accessors[prop][:configurable])
    end
    
    def has_property(prop)
      accessors.has_key?(prop) || properties.has_key?(prop) || (prototype && prototype.is_a?(Object) && prototype.has_property(prop))
    end
    
    def has_accessor(prop)
      accessors.has_key?(prop)
    end
    
    def has_own_property(prop)
      accessors.has_key?(prop) || properties.has_key?(prop)
    end
    
    def delete(prop)
      if accessors.has_key? prop
        accessors.delete prop if accessors[prop][:configurable]
      elsif prop != "prototype"
        properties.delete prop
      end
    end
    
    def delete!(prop)
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
          str = toString.call(nil, self, [])
          return str if str.is_a? Primitive
        end
        valueOf = get "valueOf"
        if valueOf.respond_to? :call
          val = valueOf.call(nil, self, [])
          return val if val.is_a? Primitive
        end
        Twostroke::Runtime::Lib.throw_type_error "could not convert object to string"
      elsif hint == "Number"
        valueOf = get "valueOf"
        if valueOf.respond_to? :call
          val = valueOf.call(nil, self, [])
          return val if val.is_a? Primitive
        end
        toString = get "toString"
        if toString.respond_to? :call
          str = toString.call(nil, self, [])
          return str if str.is_a? Primitive
        end
        Twostroke::Runtime::Lib.throw_type_error "could not convert object to string"
      end
    end
    
    def define_own_property(prop, descriptor)
      unless descriptor.has_key?(:get) || descriptor.has_key?(:set)
        descriptor[:get] = ->(this) { descriptor[:value] }
        descriptor[:set] = ->(this, value) { descriptor[:value] = value }
        descriptor[:value] ||= Undefined.new
      else
        descriptor[:writable] = true if descriptor.has_key?(:set)
      end
      accessors[prop] = descriptor
    end
  end
end