module Twostroke::Runtime
  Lib.register do |scope|
    log = Types::Function.new nil do |this, args|
      puts args.join(" ")
    end
  
    console = Types::Object.new
    ["log", "info", "warn", "error"].each do |m|
      console.set m, log
    end
    console.set "gets", Types::Function.new(->(this,args) { gets })
    console.set "_print", Types::Function.new(->(this,args) { print *args })
    scope.set_var "console", console
  end
end