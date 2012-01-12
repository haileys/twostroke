module Twostroke::Runtime
  Lib.register do |scope|
    obj = Types::Function.new(->(scope, this, args) {
        return Types::String.new Time.now.strftime("%a %b %d %Y %H:%M:%S GMT%z (%Z)") unless this.constructing?
        args.map! { |a| Types.to_primitive a }
        if args.size.zero?
          this.data[:time] = Time.now
        elsif args.size == 1
          if args[0].is_a?(Types::Number)
            this.data[:time] = Time.at *(args[0].number*1000).divmod(1000_000)
          else
            this.data[:time] = Time.parse(Types.to_string(args[0]).string) rescue this.data[:time] = :invalid
          end
        else
          args = args.take(7)
            .map { |a| Types.to_uint32(a) }
            .zip([9999, 12, 31, 23, 59, 59, 999]).map { |a,b| [a || 0, b].min }
          args[6] *= 1000 if args[6]
          this.data[:time] = Time.local *args
        end
        nil
      }, nil, "Date", [])
    scope.set_var "Date", obj
    
    obj.proto_put "now", Types::Function.new(->(scope, this, args) { Types::Number.new (Time.now.to_f * 1000).floor }, nil, "now", [])
    obj.proto_put "parse", Types::Function.new(->(scope, this, args) {
        Types::Number.new (Time.parse(Types.to_string(args[0]).string).to_f * 1000).floor
      }, nil, "parse", [])
    obj.proto_put "UTC", Types::Function.new(->(scope, this, args) {  
        return Types::Number.new Float::NAN if args.size < 2
        args = args.take(7)
          .map { |a| Types.to_uint32(a) }
          .zip([9999, 12, 31, 23, 59, 59, 999])
          .map { |a,b| [a || 0, b].min }
        args[1] += 1 if args[1]
        args[6] *= 1000 if args[6]
        Types::Number.new (Time.utc(*args).to_f * 1000).floor
      }, nil, "UTC", [])
    
    proto = Types::Object.new
    obj.proto_put "prototype", proto
    
    proto.proto_put "toString", Types::Function.new(->(scope, this, args) {
        Lib.throw_type_error "this is not a Date object" unless this.data[:time]
        Types::String.new this.data[:time].strftime("%a %b %d %Y %H:%M:%S GMT%z (%Z)")
      }, nil, "toString", [])
    proto.proto_put "valueOf", Types::Function.new(->(scope, this, args) {
        Lib.throw_type_error "this is not a Date object" unless this.data[:time]
        Types::Number.new (this.data[:time].to_f * 1000).to_i
      }, nil, "valueOf", [])
    
    { "Date" => :day, "Day" => :wday, "FullYear" => :year, "Year" => ->t{ t.year - 1900 }, "Hours" => :hour,
      "Milliseconds" => ->t{ (t.usec / 1000).to_i }, "Minutes" => :min, "Month" => :month,
      "Seconds" => :sec, "Time" => ->t{ (t.to_f * 1000).floor }, "TimezoneOffset" => ->t{ t.utc_offset / 60 } }.each do |prop,method|
        # Date.prototype.getXXX
        proto.proto_put "get#{prop}", Types::Function.new(->(scope, this, args) {
            Lib.throw_type_error "this is not a Date object" unless this.data[:time]
            return Types::Number.new(Float::NAN) if this.data[:time] == :invalid
            Types::Number.new(
              if method.is_a? Symbol then this.data[:time].send method
              elsif method.is_a? Proc then method.call this.data[:time]
              end
            )
          }, nil, "get#{prop}", [])
        # Date.prototype.getUTCXXX
        proto.proto_put "getUTC#{prop}", Types::Function.new(->(scope, this, args) {
            Lib.throw_type_error "this is not a Date object" unless this.data[:time]
            return Types::Number.new(Float::NAN) if this.data[:time] == :invalid
            Types::Number.new(
              if method.is_a? Symbol then this.data[:time].send method
              elsif method.is_a? Proc then method.call this.data[:time]
              end
            )
          }, nil, "getUTC#{prop}", [])
      end
  end
end