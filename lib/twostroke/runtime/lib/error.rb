module Twostroke::Runtime
  Lib.register do |scope|
    make_exception = ->(klass, message) do
      exc = Types::Object.new
      exc.construct prototype: klass.prototype, _class: klass do
        exc.proto_put "name", Types::String.new(klass.name)
        if message.is_a? Types::Value
          exc.proto_put "message", message
        else
          exc.proto_put "message", Types::String.new(message)
        end
        exc.data[:exception_stack] = []
        exc.define_own_property "stack", get: ->(*) {
          str = "#{Types.to_string(exc.get "name").string}: #{Types.to_string(exc.get "message").string}\n" +
            exc.data[:exception_stack].map { |line| "    #{line}" }.join("\n")
          Types::String.new(str)
        }, writable: false, enumerable: false
      end
    end
    
    error = Types::Function.new(->(scope, this, args) {
      make_exception.call error, args[0] || Types::Undefined.new
    }, nil, "Error", [])
    scope.set_var "Error", error
    error.prototype = Types::Object.new
    error.prototype.proto_put "toString", Types::Function.new(->(scope, this, args) {
      Types::String.new "#{Types.to_string(this.get "name").string}: #{Types.to_string(this.get "message").string}"
    }, nil, "toString", [])
    error.proto_put "prototype", error.prototype
    
    ["Eval", "Range", "Reference", "Syntax", "Type", "URI", "_Interrupt"].each do |e|
      obj = Types::Function.new(->(scope, this, args) {
        make_exception.call obj, args[0] || Types::Undefined.new
      }, nil, "#{e}Error", [])
      scope.set_var "#{e}Error", obj
      obj.prototype = error.prototype
      obj.proto_put "prototype", error.prototype
      Lib.define_singleton_method "throw_#{e.downcase}_error" do |message|
        throw :exception, make_exception.call(obj, message)
      end
    end
  end
end