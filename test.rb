$LOAD_PATH << File.expand_path("../lib", __FILE__)
require "twostroke"
require "pp"
require "coderay"
#require "pry"

lexer = Twostroke::Lexer.new(ARGF.read)
lexer.lex

parser = Twostroke::Parser.new lexer.tokens
parser.parse

if Object.method_defined? :pry
  pry binding
else
  red=`tput setaf 1`
  green=`tput setaf 2`
  yellow=`tput setaf 3`
  pink=`tput setaf 5`
  blue=`tput setaf 6`
  reset=`tput sgr0`
  
  #parser.statements.pretty_inspect.gsub /
  str = parser.statements.pretty_inspect
  .gsub(/<([A-Z][a-zA-Z]*(::[A-Za-z][A-Za-z]*)*)/) { |m| "<#{red}#{$1}#{reset}" }
  .gsub(/([^:])(:[a-z]+)/i)     { |m| "#{$1}#{pink}#{$2}#{reset}" }
  .gsub(/"([^"]+)"/)            { |m| "#{green}\"#{$1}\"#{reset}" }
  .gsub(/=([\d\.\d]+)/)         { |m| "=#{yellow}#{$1}#{reset}" }
  .gsub(/(@[a-z_][a-z_0-9]*)/i) { |m| "#{blue}#{$1}#{reset}" }
  
  puts str
end