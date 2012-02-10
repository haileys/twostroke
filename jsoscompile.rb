$LOAD_PATH << File.expand_path("../lib", __FILE__)
require "twostroke"
file = File.open(ARGV.first, "r:utf-8")
parser = Twostroke::Parser.new(Twostroke::Lexer.new(file.read))
parser.parse

compiler = Twostroke::Compiler::Binary.new parser.statements
compiler.compile

print compiler.bytecode