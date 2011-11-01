$LOAD_PATH << File.expand_path("../lib", __FILE__)
require "twostroke"
require "paint"

vm = Twostroke::Runtime::VM.new({})
Twostroke::Runtime::Lib.setup_environment vm

T = Twostroke::Runtime::Types
vm.global_scope.set_var "assert", T::Function.new(->(scope, this, args) {
  throw :test_failure, (args[1] ? T.to_string(args[1]).string : "") unless T.is_truthy(args[0])
}, nil, nil, [])
vm.global_scope.set_var "test", T::Function.new(->(scope, this, args) {
  test_name = T.to_string(args[0] || T::Undefined.new).string
  exception = nil
  failure = nil
  begin
    failure = catch(:test_failure) do
      exception = catch(:exception) do
        if args[1].respond_to? :call
          args[1].call(nil, vm.global_scope, [])
        else
          throw :test_failure, "" unless T.is_truthy args[1]
        end
        false
      end
      false
    end
  rescue => error
  end
  if failure
    puts "   #{Paint[" FAIL", :red]}  #{test_name}"
    puts "      Assertion failed: #{failure || "(no message)"}"
  elsif exception
    puts "   #{Paint["ERROR", :yellow]}  #{test_name}"
    puts "      Uncaught exception: #{T.to_string(exception).string}"
  elsif error
    puts "   #{Paint["ERROR", :yellow]}  #{test_name}"
    puts "      Internal Twostroke Error: #{error} at:"
    error.backtrace.each do |bt|
      puts "        #{bt}"
    end
  else
    puts "   #{Paint[" PASS", :green]}  #{test_name}"
  end
}, nil, nil, [])

Dir["test/**/*.js"].each do |test|
  puts Paint[test, :bright, :white]
  
  parser = Twostroke::Parser.new(Twostroke::Lexer.new(File.read test))
  parser.parse
  
  compiler = Twostroke::Compiler::TSASM.new parser.statements, "test_#{test}_"
  compiler.compile

  compiler.bytecode.each do |k,v|
    vm.bytecode[k] = v
  end
  
  vm.execute :"test_#{test}_main"
end