$LOAD_PATH << File.expand_path("../lib", __FILE__)
require "twostroke"

parser = Twostroke::Parser.new(Twostroke::Lexer.new(File.read ARGV.first))
parser.parse

compiler = Twostroke::Compiler::TSASM.new parser.statements
compiler.compile

if ARGV.include? "-S"
  compiler.bytecode.each do |section,instructions|
    puts "#{section}:"
    instructions.each_with_index do |ins,offset|
      puts "#{sprintf "%4d", offset}    #{ins[0]}#{" " * (12 - ins[0].size)}#{ins.drop(1).map { |x| x.is_a?(String) ? x.inspect : x }.join ", "}"
    end
  end
else
  File.open ARGV.first.gsub(/\.js$/, ".ts"), "w" do |f|
    compiler.bytecode.default = nil
    f.write Marshal.dump compiler.bytecode
  end
end