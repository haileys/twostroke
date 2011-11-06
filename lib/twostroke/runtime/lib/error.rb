module Twostroke::Runtime
  Lib.register do |scope|
    error = Types::Function.new(->(scope, this, args) {
      this.put "name", Types::String.new("Error")
      this.put "message", (args[0] || Types::Undefined.new)
      nil # so the constructor ends up returning the object being constructed
    }, nil, "Error", [])
    scope.set_var "Error", error
    error.prototype = Types::Object.new
    error.prototype.put "toString", Types::Function.new(->(scope, this, args) {
      Types::String.new "#{Types.to_string(this.get "name").string}: #{Types.to_string(this.get "message").string}"
    }, nil, "toString", [])
    error.put "prototype", error.prototype
    
    ["Eval", "Range", "Reference", "Syntax", "Type", "URI"].each do |e|
      obj = Types::Function.new(->(scope, this, args) {
        this.put "name", Types::String.new("#{e}Error")
        this.put "message", (args[0] || Types::Undefined.new)
        nil
      }, nil, "#{e}Error", [])
      scope.set_var "#{e}Error", obj
      obj.prototype = error.prototype
#      proto = Types::Object.new
#      proto.prototype = error.prototype
      obj.put "prototype", error.prototype
      Lib.define_singleton_method "throw_#{e.downcase}_error" do |message|
        exc = Types::Object.new
        exc.construct prototype: obj.prototype, _class: obj do
          exc.put "name", Types::String.new("#{e}Error")
          exc.put "message", Types::String.new(message)
        end
        throw :exception, exc
      end
    end
  end
end