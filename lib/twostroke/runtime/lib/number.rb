module Twostroke::Runtime
  Lib.register do |scope|
    obj = Types::NumberObject.constructor_function
    scope.set_var "Number", obj
    
    proto = Types::Object.new
    proto.put "toString", Types::Function.new(->(scope, this, args) {
      if this.is_a?(Types::NumberObject)
        Types::String.new(this.number.to_s)
      else
        Lib.throw_type_error "Number.prototype.toString is not generic"
      end
    }, nil, "toString", [])
    proto.put "valueOf", Types::Function.new(->(scope, this, args) { this.is_a?(Types::NumberObject) ? Types::Number.new(this.number) : Types.to_primitive(this) }, nil, "valueOf", [])
    # Number.prototype.toExponential
    proto.put "toExponential", Types::Function.new(->(scope, this, args) do
        n = Types.to_number(this)
        if n.nan? || n.infinite?
          Types::String.new n.to_s
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
    proto.put "toFixed", Types::Function.new(->(scope, this, args) do
        digits = Types.to_number(args[0] || Undefined.new)
        if digits.nan? || digits.infinite?
          digits = 0
        else
          digits = digits.number
        end
        Types::String.new sprintf("%.#{[[0,digits].max,20].min}f", Types.to_number(this).number)
      end, nil, "toFixed", [])
    # Number.prototype.toLocaleString
    proto.put "toLocaleString", proto.get("toString")
    # Number.prototype.toString
    proto.put "toPrecision", Types::Function.new(->(scope, this, args) do
        digits = Types.to_number(args[0] || Undefined.new)
        if digits.nan? || digits.infinite?
          digits = 0
        else
          digits = digits.number
        end
        Types::Number.new Types.to_number(this).number.round([[digits,0].max, 100].min)
      end, nil, "toString", [])
    obj.put "prototype", proto
    obj.put "MAX_VALUE", Types::Number.new(Float::MAX)
    obj.put "MIN_VALUE", Types::Number.new(Float::MIN)
    obj.put "NaN", Types::Number.new(Float::NAN)
    obj.put "NEGATIVE_INFINITY", Types::Number.new(Float::INFINITY)
    obj.put "POSITIVE_INFINITY", Types::Number.new(-Float::INFINITY)
  end
end