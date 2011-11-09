$LOAD_PATH << File.expand_path("../lib", __FILE__)
require "twostroke"

parser = Twostroke::Parser.new(Twostroke::Lexer.new(File.read ARGV.first))
parser.parse

compiler = Twostroke::Compiler::TSASM.new parser.statements
compiler.compile

vm = Twostroke::Runtime::VM.new compiler.bytecode
Twostroke::Runtime::Lib.setup_environment vm

if ARGV.include? "--pry"
  require "pry"
  pry binding
end

ex = catch(:exception) { vm.execute; nil }
if ex
  puts "Uncaught exception: #{Twostroke::Runtime::Types.to_string(ex).string}"
  exit 1
end