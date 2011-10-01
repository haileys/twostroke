$LOAD_PATH << File.expand_path("../lib", __FILE__)
require "twostroke"
require "pry"

lexer = Twostroke::Lexer.new(ARGF.read)
lexer.lex

parser = Twostroke::Parser.new lexer.tokens
parser.parse

pry binding

#p parser.statements