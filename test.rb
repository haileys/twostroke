if ENV["NO_SIMPLECOV"]
  require "simplecov"
  SimpleCov.start
end

$LOAD_PATH << File.expand_path("../lib", __FILE__)
require "twostroke"
require "paint"

vm = Twostroke::Runtime::VM.new({})
Twostroke::Runtime::Lib.setup_environment vm

asserts = 0
failed = false

$cur_test = nil
T = Twostroke::Runtime::Types
vm.global_scope.set_var "assert", T::Function.new(->(scope, this, args) {
  throw :test_failure, (args[1] ? T.to_string(args[1]).string : "") unless T.is_truthy(args[0])
  asserts += 1
}, nil, nil, [])
vm.global_scope.set_var "assert_equal", T::Function.new(->(scope, this, args) {
  throw :test_failure, "<#{T.to_string(args[0]).string}> !== <#{T.to_string(args[1]).string}>  #{T.to_string(args[2]).string if args[2]}" unless T.seq args[0], args[1]
  asserts += 1
}, nil, nil, [])
vm.global_scope.set_var "test", T::Function.new(->(scope, this, args) {
  test_name = T.to_string(args[0] || T::Undefined.new).string
  exception = nil
  failure = nil
  asserts = 0
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
    failed = true
    puts
    puts "#{Paint[$cur_test, :bright, :white]}"
    puts "   #{Paint[" FAIL", :red]}  #{test_name}"
    puts "      Assertion failed after #{asserts} assertions: #{failure || "(no message)"}"
  elsif exception
    failed = true
    puts
    puts "#{Paint[$cur_test, :bright, :white]}"
    puts "   #{Paint["ERROR", :yellow]}  #{test_name}"
    puts "      Uncaught exception after #{asserts} assertions: #{T.to_string(exception).string}"
  elsif error
    failed = true
    puts
    puts "#{Paint[$cur_test, :bright, :white]}"
    puts "   #{Paint["ERROR", :yellow]}  #{test_name}"
    puts "      Internal error after #{asserts} assertions: #{error} at:"
    error.backtrace.each do |bt|
      puts "        #{bt}"
    end
  else
    print "."
#    puts "   #{Paint[" PASS", :green]}  #{test_name}"
  end
}, nil, nil, [])

if ARGV.empty?
  tests = Dir["test/**/*.js"]
else
  tests = ARGV.map { |f| "test/#{f}.js" }
end

tests.each do |test|
#  puts Paint[test, :bright, :white]
  $cur_test = test
  src = File.read test
  
  parser = Twostroke::Parser.new(Twostroke::Lexer.new(src))
  parser.parse
  
  compiler = Twostroke::Compiler::TSASM.new parser.statements, "test_#{test}_"
  compiler.compile

  compiler.bytecode.each do |k,v|
    vm.bytecode[k] = v
  end
  
  exception = catch(:exception) do
    vm.execute :"test_#{test}_main"
    nil
  end
  
  if exception
    puts "   #{Paint["ERROR", :yellow]}"
    puts "      Uncaught exception: #{T.to_string(exception).string}"
  end
end

exit(failed ? 1 : 0)