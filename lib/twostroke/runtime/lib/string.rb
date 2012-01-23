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
    # String.prototype.substring
    proto.proto_put "substring", Types::Function.new(->(scope, this, args) {
        indexA = args[0] && Types.to_int32(args[0])
        indexB = args[1] && Types.to_int32(args[1])
        str = Types.to_string(this).string
        return Types::String.new(str) unless indexA
        return Types::String.new(str[indexA..-1] || "") unless indexB
        indexA, indexB = indexB, indexA if indexB < indexA
        Types::String.new(str[indexA...indexB] || "")
      }, nil, "substring", [])
    # String.prototype.substr
    proto.proto_put "substr", Types::Function.new(->(scope, this, args) {
        index = args[0] && Types.to_int32(args[0])
        len = args[1] && Types.to_uint32(args[1])
        str = Types.to_string(this).string
        return Types::String.new(str) unless index
        return Types::String.new(str[index..-1] || "") unless len
        Types::String.new(str[index, len] || "")
      }, nil, "substr", [])
    # String.prototype.slice
    proto.proto_put "slice", Types::Function.new(->(scope, this, args) {
        sobj = Types.to_string(this)
        s = sobj.string
        if args[0].nil?
          sobj
        else
          start = Types.to_int32 args[0]
          if args[1]
            fin = Types.to_int32 args[1]
            Types::String.new s[start...fin]
          else
            Types::String.new s[start..-1]
          end
        end
      }, nil, "slice", [])
    # String.prototype.indexOf
    proto.proto_put "indexOf", Types::Function.new(->(scope, this, args) {
        idx = args[1] ? Types.to_int32(args[1]) : 0
        Types::Number.new(Types.to_string(this).string.index(Types.to_string(args[0] || Types::Undefined.new).string, idx) || -1)
      }, nil, "indexOf", [])
    # String.prototype.lastIndexOf
    proto.proto_put "lastIndexOf", Types::Function.new(->(scope, this, args) {
        idx = args[1] ? Types.to_int32(args[1]) : -1
        Types::Number.new(Types.to_string(this).string.rindex(Types.to_string(args[0] || Types::Undefined.new).string, idx) || -1)
      }, nil, "lastIndexOf", [])
    # String.prototype.charAt
    proto.proto_put "charAt", Types::Function.new(->(scope, this, args) {
        idx = args[0] ? Types.to_int32(args[0]) : 0
        str = Types.to_string(this).string
        if idx < 0 or idx >= str.length
          Types::String.new ""
        else
          Types::String.new str[idx]
        end
      }, nil, "charAt", [])
    # String.prototype.charAt
    proto.proto_put "charCodeAt", Types::Function.new(->(scope, this, args) {
        idx = args[0] ? Types.to_int32(args[0]) : 0
        str = Types.to_string(this).string
        if idx < 0 or idx >= str.length
          Types::Number.new Float::NAN
        else
          Types::Number.new str[idx].ord
        end
      }, nil, "charCodeAt", [])
    # String.prototype.match
    proto.proto_put "match", Types::Function.new(->(scope, this, args) {
        re = args[0] || Types::Undefined.new
        re = Types::RegExp.constructor_function.(nil, nil, re) unless re.is_a?(Types::RegExp)
        unless re.global
          # same as re.exec(str) in this case
          Types::RegExp.exec(nil, re, [this])
        else
          Types::RegExp.all_matches(nil, re, [this])
        end
      }, nil, "match", [])
    # String.prototype.toUpperCase
    proto.proto_put "toUpperCase", Types::Function.new(->(scope, this, args) {
        Types::String.new Types.to_string(this).string.upcase
      }, nil, "toUpperCase", [])
    # String.prototype.toUpperCase
    proto.proto_put "toLowerCase", Types::Function.new(->(scope, this, args) {
        Types::String.new Types.to_string(this).string.downcase
      }, nil, "toLowerCase", [])
    obj.proto_put "prototype", proto
    
    obj.proto_put "fromCharCode", Types::Function.new(->(scope, this, args) {
        Types::String.new args.map { |a| Types.to_number(a).number.to_i.chr }.join
      }, nil, "fromCharCode", [])
  end
end