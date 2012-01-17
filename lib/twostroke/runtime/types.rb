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
        object.string != ""
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
      to_number to_primitive(object, "Number")
    end
  end
  
  def self.to_int32(object)
    num = to_number object
    if num.nan? || num.infinite?
      0
    else
      int32 = num.number.to_i & 0xffff_ffff
      int32 -= 2 ** 32 if int32 >= 2 ** 31
      int32
    end
  end
  
  def self.to_uint32(object)
    num = to_number object
    if num.nan? || num.infinite?
      0
    else
      num.number.to_i & 0xffff_ffff
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
      String.new object.number.to_s.gsub(/\.0+\z/,"")
    elsif object.is_a?(String)
      object
    else
      to_string to_primitive(object, "String")
    end
  end
  
  def self.to_object(object)
    if object.is_a?(Undefined) || object.is_a?(Null)
      Twostroke::Runtime::Lib.throw_type_error "cannot convert null or undefined to object"
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
    !is_truthy(object)
  end
  
  def self.is_truthy(object)
    to_boolean(object).boolean
  end
  
  def self.eq(a, b)
    if a.class == b.class
      a === b
    elsif a.is_a?(Null) && b.is_a?(Undefined)
      true
    elsif a.is_a?(Undefined) && b.is_a?(Null)
      true
    elsif a.is_a?(Number) && b.is_a?(String)
      eq(a, to_number(b))
    elsif a.is_a?(String) && b.is_a?(Number)
      eq(to_number(a), b)
    elsif a.is_a?(Boolean)
      eq(to_number(a), b)
    elsif b.is_a?(Boolean)
      eq(a, to_number(b))
    elsif (a.is_a?(String) || b.is_a?(Number)) && b.is_a?(Object)
      eq(a, to_primitive(b))
    elsif a.is_a?(Object) && (b.is_a?(String) || b.is_a?(Number))
      eq(to_primitive(a), b)
    else
      false
    end
  end
  
  def self.seq(a, b)
    if a.class == b.class
      a === b
    else
      false
    end
  end
  
  def self.marshal(ruby_object)
    case ruby_object
    when ::String;          String.new ruby_object
    when Fixnum, Float;     Number.new ruby_object
    when ::Array;           Array.new ruby_object.map { |el| box el }
    when Hash;              o = Object.new
                            ruby_object.each { |k,v| o.put k.to_s, box(v) }
                            o
    when nil;               Null.new
    when true;              Boolean.true
    when false;             Boolean.false
    else                    Undefined.new
    end
  end
  
  require File.expand_path("../types/value.rb", __FILE__)
  require File.expand_path("../types/object.rb", __FILE__)
  Dir.glob(File.expand_path("../types/*", __FILE__)).each do |f|
    require f
  end
end