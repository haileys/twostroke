module Twostroke::Runtime
  Lib.register do |scope|
    obj = Types::StringObject.constructor_function
    scope.set_var "String", obj
    
    proto = Types::Object.new
    # String.prototype.toString
    proto.proto_put "toString", Types::Function.new(->(scope, this, args) {
        if this.is_a?(Types::StringObject)
          Types::String.new(this.string)
        else
          Lib.throw_type_error "String.prototype.toString is not generic"
        end
      }, nil, "toString", [])
    # String.prototype.valueOf
    proto.proto_put "valueOf", Types::Function.new(->(scope, this, args) { this.is_a?(Types::StringObject) ? Types::String.new(this.string) : Types.to_primitive(this) }, nil, "valueOf", [])
    # String.prototype.split
    proto.proto_put "split", Types::Function.new(->(scope, this, args) {
        sep = Types.to_string(args[0] || Types::Undefined.new).string
        str = Types.to_string(this).string
        Types::Array.new (if args[1]
            str.split sep, Types.to_uint32(args[1])
          else
            str.split sep
          end).map { |s| Types::String.new s }
      }, nil, "split", [])
    # String.prototype.length
    proto.define_own_property "length", get: ->(this) { Types::Number.new this.string.size }, writable: false, enumerable: false
    # String.prototype.replace
    proto.proto_put "replace", Types::Function.new(->(scope, this, args) {
        sobj = Types.to_string(this)
        s = sobj.string
        
        find = args[0] || Types::Undefined.new
        re = find.is_a?(Types::RegExp) ? find.regexp : Regexp.new(Regexp.escape Types.to_string(find).string)
        global = find.is_a?(Types::RegExp) && find.global
        
        replace = args[1] || Types::Undefined.new
        callback = replace.respond_to?(:call) ? replace : ->(*_) { replace }
        
        retn = ""
        offset = 0
        loop do
          md = re.match s, offset
          break unless md && (offset.zero? || global)
          retn << md.pre_match[offset..-1]
          retn << Types.to_string(callback.(scope, nil, [*md.to_a.map { |c| Types::String.new c }, Types::Number.new(md.begin 0), sobj])).string
          offset = md.end 0
        end
        
        retn << s[offset..-1]

        Types::String.new retn
      }, nil, "replace", [])
=begin
        find = args[0] || Types::Undefined.new
        find = Types.to_string(find).string unless find.is_a?(Types::RegExp)
        replace = args[1] || Types::Undefined.new
        replace = Types.to_string(replace).string unless replace.respond_to? :call        
        Types::String.new(if find.is_a?(String)
          if replace.is_a?(String)
            s.sub find, replace
          else
            s.sub(find) { |m| Types.to_string(replace.call(scope, nil, [Types::String.new(m), Types::Number.new(s.index m), sobj])).string }
          end
        else
          m = s.method(find.global ? :gsub : :sub)
          if replace.is_a?(String)
            m.(find.regexp, replace)
          else
            offset = 0
            m.(find.regexp) do |m|
              idx = s.index m, offset
              offset = idx + m.size
              Types.to_string(replace.call(scope, nil, [Types::String.new(m), Types::Number.new(idx), sobj])).string
            end
          end
        end)
=end
    obj.proto_put "prototype", proto
    
    obj.proto_put "fromCharCode", Types::Function.new(->(scope, this, args) {
        Types::String.new args.map { |a| Types.to_number(a).number.to_i.chr }.join
      }, nil, "fromCharCode", [])
  end
end