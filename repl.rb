$LOAD_PATH << File.expand_path("../lib", __FILE__)
require "twostroke"
T = Twostroke::Runtime::Types
require "paint"

bytecode = {}
vm = Twostroke::Runtime::VM.new bytecode
Twostroke::Runtime::Lib.setup_environment vm.global_scope

sect = 0

trap "SIGINT" do
  print "\r"
  exit!
end

loop do
  print Paint[">>> ", :bright]
  src = $stdin.gets.chomp + ";"

  begin
    parser = Twostroke::Parser.new(Twostroke::Lexer.new(src))
    parser.parse
  
    sect += 1
    compiler = Twostroke::Compiler::TSASM.new parser.statements, "repl_#{sect}_"
    compiler.compile
  
    compiler.bytecode.each do |k,v|
      bytecode[k] = v
    end
  
    bytecode[:"repl_#{sect}_main"][-2] = [:ret] # hacky way to make main return the last evaluated value
    obj = vm.execute :"repl_#{sect}_main"
    str = if obj.is_a? T::String
      Paint[obj.string.inspect, :green]
    elsif obj.is_a? T::Number
      Paint[obj.number.inspect, :cyan]
    elsif obj.is_a? T::Boolean
      Paint[obj.boolean.inspect, :magenta]
    elsif obj.is_a?(T::Null)
      Paint["null", :yellow]
    elsif obj.is_a?(T::Undefined)
      Paint["undefined", :yellow]
    else
      Twostroke::Runtime::Types.to_string(obj).string
    end
    puts " => #{str}"
  rescue => e
    if ARGV.include? "--debug"
      puts "#{e.class.name}: #{e.message}"
      e.backtrace.each { |s| puts "  #{s}" }
    else
      puts "#{e.class.name}: #{e.message}"
    end
  end
end


=begin
vm = Twostroke::Runtime::VM.new compiler.bytecode
Twostroke::Runtime::Lib.setup_environment vm.global_scope

if ARGV.include? "--pry"
  require "pry"
  pry binding
end

vm.execute
=end