module Twostroke::Runtime
  Lib.register do |scope|
    error = Types::Function.new(->(scope, this, args) {
      this.proto_put "name", Types::String.new("Error")
      this.proto_put "message", (args[0] || Types::Undefined.new)
      this.data[:exception_stack] = []
      this.define_own_property "stack", get: ->(*) {
          str = "#{Types.to_string(this.get "name").string}: #{Types.to_string(this.get "message").string}\n" +
            this.data[:exception_stack].map { |line| "    #{line}" }.join("\n")
          Types::String.new(str)
        }, writable: false, enumerable: false
      nil # so the constructor ends up returning the object being constructed
    }, nil, "Error", [])
    scope.set_var "Error", error
    error.prototype = Types::Object.new
    error.prototype.proto_put "toString", Types::Function.new(->(scope, this, args) {
      Types::String.new "#{Types.to_string(this.get "name").string}: #{Types.to_string(this.get "message").string}"
    }, nil, "toString", [])
    error.proto_put "prototype", error.prototype
    
    ["Eval", "Range", "Reference", "Syntax", "Type", "URI", "_Interrupt"].each do |e|
      obj = Types::Function.new(->(scope, this, args) {
        this.proto_put "name", Types::String.new("#{e}Error")
        this.proto_put "message", (args[0] || Types::Undefined.new)
        this.data[:exception_stack] = []
        this.define_own_property "stack", get: ->(*) {
            str = "#{Types.to_string(this.get "name").string}: #{Types.to_string(this.get "message").string}\n" +
              this.data[:exception_stack].map { |line| "    #{line}" }.join("\n")
            Types::String.new(str)
          }, writable: false, enumerable: false
        nil
      }, nil, "#{e}Error", [])
      scope.set_var "#{e}Error", obj
      obj.prototype = error.prototype
#      proto = Types::Object.new
#      proto.prototype = error.prototype
      obj.proto_put "prototype", error.prototype
      Lib.define_singleton_method "throw_#{e.downcase}_error" do |message|
        exc = Types::Object.new
        exc.construct prototype: obj.prototype, _class: obj do
          exc.proto_put "name", Types::String.new("#{e}Error")
          exc.proto_put "message", Types::String.new(message)
          exc.data[:exception_stack] = []
          exc.define_own_property "stack", get: ->(*) {
            str = "#{Types.to_string(exc.get "name").string}: #{Types.to_string(exc.get "message").string}\n" +
              exc.data[:exception_stack].map { |line| "    #{line}" }.join("\n")
            Types::String.new(str)
          }, writable: false, enumerable: false
        end
        throw :exception, exc
      end
    end
  end
end