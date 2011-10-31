module Twostroke::Runtime::Types
  def self.to_primitive(object, preferred_type = nil)
    if object.is_a? Primitive
      object
    else
      object.default_value preferred_type
    end
  end
  
  def self.to_boolean(object)
    b = if object.is_a?(Boolean)
        object.boolean
      elsif object.is_a?(Undefined) || object.is_a?(Null)
        false
      elsif object.is_a?(Number)
        !object.zero? && !object.nan?
      elsif object.is_a?(String)
        object.string == ""
      else
        true
      end
    Boolean.new b
  end
  
  def self.to_number(object)
    if object.is_a?(Undefined)
      Number.new Float::NAN
    elsif object.is_a?(Null)
      Number.new 0
    elsif object.is_a?(Boolean)
      Number.new(object.boolean ? 1 : 0)
    elsif object.is_a?(Number)
      object
    elsif object.is_a?(String)
      Number.new(Float(object.string)) rescue Number.new(Float::NAN)
    else # object is Object
      to_number to_primitive(object)
    end
  end
  
  def self.to_string(object)
    if object.is_a?(Undefined)
      String.new "undefined"
    elsif object.is_a?(Null)
      String.new "null"
    elsif object.is_a?(Boolean)
      String.new object.boolean.to_s
    elsif object.is_a?(Number)
      String.new object.number.to_s
    elsif object.is_a?(String)
      object
    else
      to_string to_primitive(object)
    end
  end
  
  def self.to_object(object)
    if object.is_a?(Undefined) || object.is_a?(Null)
      raise "TypeError: cannot convert null or undefined to object" #@TODO
    elsif object.is_a?(Boolean)
      BooleanObject.new object.boolean
    elsif object.is_a?(Number)
      NumberObject.new object.number
    elsif object.is_a?(String)
      StringObject.new object.string
    else
      object
    end
  end
  
  def self.is_falsy(object)
    if object.is_a?(Boolean)
      !object.boolean
    elsif object.is_a?(Null) || object.is_a?(Undefined)
      true
    elsif object.is_a?(String)
      object.string == ""
    elsif object.is_a?(Number)
      object.zero? || object.nan?
    else
      false
    end
  end
  
  def self.is_truthy(object)
    !is_falsy(object)
  end
  
=begin
  # type convesions
  def self.to_boolean(obj)
    if obj.nil?
      false
    else
      promote_primitive(obj).to_boolean
    end
  end
  
  def self.to_number(obj)
    if obj.nil?
      ::Float::NAN
    else
      promote_primitive(obj).to_number
    end
  end
  
  def self.to_string(obj)
    if obj.nil?
      "undefined"
    else
      promote_primitive(obj).to_string
    end
  end
  
  def self.promote_primitive(obj)
    if obj.nil?
      nil
    elsif obj == true || obj == false
      Boolean.new obj
    elsif obj.is_a?(::Fixnum) || obj.is_a?(::Float)
      Number.new obj
    elsif obj.is_a?(::String)
      String.new obj
    else
      obj
    end
  end
  
  def self.is_truthy(obj)
    !is_falsy(obj)
  end
  
  def self.is_falsy(obj)
    obj = promote_primitive obj
    if obj.is_a?(Boolean) && obj.boolean == false
      true
    elsif obj.is_a?(Null)
      true
    elsif obj.nil?
      true
    elsif obj.is_a?(String) && obj.string == ""
      true
    elsif obj.is_a?(Number) && (obj.number.zero? || (obj.number.is_a?(::Float) && obj.number.nan?))
      true
    else
      false
    end
  end
  
=begin
  def self.eq(a, b)
    ## See ECMA-262 Section 11.9.3
    if a.ancestors.include?(Object) && b.ancestors.include?(Object)
      a == b
    elsif a.class == b.class
      if a.nil?
        true
      elsif a.is_a?(Types::Null)
        true
      elsif a.is_a?(::Fixnum) || a.is_a?(::Float)
        if a.is_a?(::Float) && a.nan?
          false
        elsif b.is_a?(::Float) && b.nan?
          false
        else
          a == b
        end
      elsif a.is_a?(::String)
        a == b
      elsif a == true || a == false
        a == b
      else
        a == b
      end
    elsif a.is_a?(Null) && b.nil?
      true
    elsif a.nil? && b.is_a?(Null)
      true
    elsif (a.is_a?(::Float) || a.is_a?(::Fixnum) || a.is_a?(Number)) && (b.is_a?(::String) || b.is_a?(String))
      to_number(a) == to_number(b)
    elsif (a.is_a?(::String) || a.is_a?(String)) && (b.is_a?(::Float) || b.is_a?(::Fixnum) || b.is_a?(Number))
      to_number(a) == to_number(b)
    elsif a == true || a == false || a.is_a?(Boolean)
      to_number(a) == b
    end
  end
=end
  
  require File.expand_path("../types/value.rb", __FILE__)
  require File.expand_path("../types/object.rb", __FILE__)
  Dir.glob(File.expand_path("../types/*", __FILE__)).each do |f|
    require f
  end
end