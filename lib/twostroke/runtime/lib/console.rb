module Twostroke::Runtime
  Lib.register do |scope|
    log = Types::Function.new nil do |this, *args|
      puts args.join(" ")
    end
  
    console = Types::Object.new
    ["log", "info", "warn", "error"].each do |m|
      console.set m, log
    end
    scope.set_var "console", console
  end
end