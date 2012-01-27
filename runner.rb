$LOAD_PATH << File.expand_path("../lib", __FILE__)
require "twostroke"

src = File.read ARGV.first
begin
  bytecode = Marshal.load src
rescue
  parser = Twostroke::Parser.new Twostroke::Lexer.new src
  parser.parse

  compiler = Twostroke::Compiler::TSASM.new parser.statements
  compiler.compile
  bytecode = compiler.bytecode
end

vm = Twostroke::Runtime::VM.new bytecode
Twostroke::Runtime::Lib.setup_environment vm

trap("SIGINT") { Twostroke::Runtime::Lib.throw__interrupt_error "SIGINT" }

if ARGV.include? "--pry"
  require "pry"
  pry binding
end

ex = catch(:exception) { vm.execute; nil }
if ex
  if ex.respond_to? :get and stack = ex.get("stack") and stack.is_a? Twostroke::Runtime::Types::String
    puts stack.string
  else
    puts "Uncaught exception: #{Twostroke::Runtime::Types.to_string(ex).string}"
  end
  exit 1
end

if ARGV.include? "--post-pry"
  require "pry"
  pry binding
end