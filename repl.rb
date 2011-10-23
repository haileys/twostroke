$LOAD_PATH << File.expand_path("../lib", __FILE__)
require "twostroke"

bytecode = {}
vm = Twostroke::Runtime::VM.new bytecode
Twostroke::Runtime::Lib.setup_environment vm.global_scope

sect = 0

loop do
  print ">> "
  src = gets.chomp + ";"

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
    puts "=> #{vm.execute :"repl_#{sect}_main"}"
  rescue
    puts "#{$!.class.name}: #{$!.message}"
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