module Twostroke::Runtime::Lib
  INITIALIZERS = []
  
  def self.setup_environment(vm)
    INITIALIZERS.each { |i| i.arity == 1 ? i.(vm.global_scope) : i.(vm.global_scope, vm) }
  end
  
  def self.register(&bk)
    INITIALIZERS << bk
  end
  
  Dir.glob File.expand_path("../lib/*.rb", __FILE__) do |f|
    require f
  end
  
  class << self    
    Dir.glob File.expand_path("../lib/*.js", __FILE__) do |f|
      INITIALIZERS << ->(global_scope, vm) {
        parser = Twostroke::Parser.new(Twostroke::Lexer.new(File.read f))
        parser.parse

        compiler = Twostroke::Compiler::TSASM.new parser.statements, "lib_#{f}_"
        compiler.compile

        compiler.bytecode.each do |k,v|
          vm.bytecode[k] = v
        end

        vm.execute :"lib_#{f}_main", global_scope
      }
    end
  end
end