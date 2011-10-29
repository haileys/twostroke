module Twostroke::Runtime
  Lib.register do |scope|    
    log = Types::Function.new(->(scope, this, args) { puts args.map { |o| Types.to_string(o).string }.join(" ") }, nil, "log", ["string"])
  
    console = Types::Object.new
    ["log", "info", "warn", "error"].each do |m|
      console.put m, log
    end
    console.put "_gets", Types::Function.new(->(scope, this, args) { Types::String.new gets }, nil, "_gets", [])
    console.put "_print", Types::Function.new(->(scope, this, args) { print args.map { |o| Types.to_string(o).string }.join(" ") }, nil, "_print", ["string"])
    scope.set_var "console", console
  end
end