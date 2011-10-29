module Twostroke::Runtime
  Lib.register do |scope|
    obj = Types::NumberObject.constructor_function
    scope.set_var "Number", obj
    
    proto = Types::Object.new
    proto.put "toString", Types::Function.new(->(scope, this, args) { this.is_a?(Types::NumberObject) ? Types::String.new(this.number.to_s) : raise("TypeError: @TODO") }, nil, "toString", [])
    proto.put "valueOf", Types::Function.new(->(scope, this, args) { this.is_a?(Types::NumberObject) ? Types::Number.new(this.number) : Types.to_primitive(this) }, nil, "valueOf", [])
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
    
    obj.put "prototype", proto
    obj.put "MAX_VALUE", Types::Number.new(Float::MAX)
    obj.put "MIN_VALUE", Types::Number.new(Float::MIN)
    obj.put "NaN", Types::Number.new(Float::NAN)
    obj.put "NEGATIVE_INFINITY", Types::Number.new(Float::INFINITY)
    obj.put "POSITIVE_INFINITY", Types::Number.new(-Float::INFINITY)
  end
end