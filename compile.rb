$LOAD_PATH << File.expand_path("../lib", __FILE__)
require "twostroke"

parser = Twostroke::Parser.new(Twostroke::Lexer.new(File.read ARGV.first))
parser.parse

compiler = Twostroke::Compiler.new parser.statements
compiler.compile

puts compiler.src