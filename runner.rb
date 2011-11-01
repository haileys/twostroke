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

vm.execute