module Twostroke::Runtime::Types
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
    if obj.nil? || obj.is_a?(Null)
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
  
  Dir.glob File.expand_path("../types/*", __FILE__) do |f|
    require f
  end
end