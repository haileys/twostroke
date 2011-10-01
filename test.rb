$LOAD_PATH << File.expand_path("../lib", __FILE__)
require "twostroke"
require "pp"
#require "pry"

lexer = Twostroke::Lexer.new(ARGF.read)
lexer.lex

parser = Twostroke::Parser.new lexer.tokens
parser.parse

if Object.method_defined? :pry
  pry binding
else
  pp parser.statements
end