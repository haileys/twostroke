$LOAD_PATH << File.expand_path("../lib", __FILE__)
require "twostroke"
require "bundler/setup"
require "pp"
require "coderay"
require "pry"

output = nil

def time(name)
  start = Time.now.to_f
  yield
  finish = Time.now.to_f
  puts "#{name}: #{((finish-start)*1000).round 1} ms"
end

def pretty(obj)
  red=`tput setaf 1`
  green=`tput setaf 2`
  yellow=`tput setaf 3`
  pink=`tput setaf 5`
  blue=`tput setaf 6`
  reset=`tput sgr0`
  
  obj.pretty_inspect
    .gsub(/<([A-Z][a-zA-Z]*(::[A-Za-z][A-Za-z]*)*)/) { |m| "<#{red}#{$1}#{reset}" }
    .gsub(/([^:])(:[a-z]+)/i)     { |m| "#{$1}#{pink}#{$2}#{reset}" }
    .gsub(/"([^"]+)"/)            { |m| "#{green}\"#{$1}\"#{reset}" }
    .gsub(/=([\d\.\d]+)/)         { |m| "=#{yellow}#{$1}#{reset}" }
    .gsub(/(@[a-z_][a-z_0-9]*)/i) { |m| "#{blue}#{$1}#{reset}" }
end

lexer = Twostroke::Lexer.new(File.read ARGV.first)
if ARGV.include? "--tokens"
  output = []
  while lexer.str.size > 0
    puts inspect(lexer.read_token)
  end
elsif ARGV.include? "--bench"
  time "lexing" do
    lexer.read_token while lexer.str.size > 0
  end
  lexer = Twostroke::Lexer.new(File.read ARGV.first)
  time "parsing" do
    parser = Twostroke::Parser.new lexer
    parser.parse
  end
  exit
else
  parser = Twostroke::Parser.new lexer
  parser.parse
  output = parser.statements
end

puts pretty(output)