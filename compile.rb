$LOAD_PATH << File.expand_path("../lib", __FILE__)
require "twostroke"

parser = Twostroke::Parser.new(Twostroke::Lexer.new(File.read ARGV.first))
parser.parse

compiler = Twostroke::Compiler::TSASM.new parser.statements
compiler.compile

require "pry"
pry binding

#=begin
compiler.bytecode.each do |section,instructions|
  puts "#{section}:"
  instructions.each do |ins|
    puts "    #{ins[0]}#{" " * (12 - ins[0].size)}#{ins.drop(1).map { |x| x.is_a?(String) ? x.inspect : x }.join ", "}"
  end
end
#=end

#print compiler.tscode