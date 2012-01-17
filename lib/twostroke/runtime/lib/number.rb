module Twostroke::Runtime
  Lib.register do |scope|
    obj = Types::NumberObject.constructor_function
    scope.set_var "Number", obj
    
    proto = Types::Object.new
    proto.proto_put "toString", Types::Function.new(->(scope, this, args) {
      if this.is_a?(Types::NumberObject)
        base = args[0] ? Types.to_uint32(args[0]) : 10
        Lib.throw_range_error "toString() radix argument must be between 2 and 36" if base < 2 or base > 36
        if this.number.is_a? Fixnum or this.number.is_a? Bignum
          Types::String.new this.number.to_s base
        else
          Types::String.new(this.number.to_s.gsub(/\.?0+\z/,""))
        end
      else
        Lib.throw_type_error "Number.prototype.toString is not generic"
      end
    }, nil, "toString", [])
    proto.proto_put "valueOf", Types::Function.new(->(scope, this, args) { this.is_a?(Types::NumberObject) ? Types::Number.new(this.number) : Types.to_primitive(this) }, nil, "valueOf", [])
    # Number.prototype.toExponential
    proto.proto_put "toExponential", Types::Function.new(->(scope, this, args) do
        n = Types.to_number(this)
        if n.nan? || n.infinite?
          Types::String.new n.number.to_s
        else
          places = Math.log(n.number, 10).floor
          significand = n.number / (10 ** places).to_f
          if args.size > 0
            sigfigs = Types.to_number(args[0] || Types::Undefined.new)
            if sigfigs.nan? || sigfigs.infinite?
              sigfigs = 0
            else
              sigfigs = sigfigs.number.to_i
            end
            Types::String.new sprintf("%.#{sigfigs}fe%s%d", significand, ("+" if places >= 0), places)
          else
            Types::String.new "#{significand}e#{"+" if places >= 0}#{places}"
          end
        end
      end, nil, "toExponential", [])
    # Number.prototype.toFixed
    proto.proto_put "toFixed", Types::Function.new(->(scope, this, args) do
        digits = Types.to_number(args[0] || Types::Undefined.new)
        if digits.nan? || digits.infinite?
          digits = 0
        else
          digits = digits.number
        end
        digits = [[0,digits].max,20].min
        Types::String.new sprintf("%.#{digits}f", Types.to_number(this).number.round(digits))
      end, nil, "toFixed", [])
    # Number.prototype.toLocaleString
    proto.proto_put "toLocaleString", proto.get("toString")
    # Number.prototype.toString
    proto.proto_put "toPrecision", Types::Function.new(->(scope, this, args) do
        n = Types.to_number(this).number
        return Types::String.new(n.to_s) unless args[0]
        digits = Types.to_number(args[0] || Types::Undefined.new)
        if digits.nan? || digits.infinite?
          digits = 0
        else
          digits = digits.number
        end
        Lib.throw_range_error "toPrecision() argument must be between 1 and 21" unless (1..21).include? digits
        fixup = 10 ** Math.log(n, 10).floor
        n /= fixup.to_f
        n = n.round digits - fixup
        Types::String.new (n * fixup).to_s
      end, nil, "toString", [])
    obj.proto_put "prototype", proto
    obj.proto_put "MAX_VALUE", Types::Number.new(Float::MAX)
    obj.proto_put "MIN_VALUE", Types::Number.new(Float::MIN)
    obj.proto_put "NaN", Types::Number.new(Float::NAN)
    obj.proto_put "NEGATIVE_INFINITY", Types::Number.new(-Float::INFINITY)
    obj.proto_put "POSITIVE_INFINITY", Types::Number.new(Float::INFINITY)
  end
end