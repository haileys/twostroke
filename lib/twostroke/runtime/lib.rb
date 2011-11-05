module Twostroke::Runtime
  module Lib
    INITIALIZERS = []
  
    def self.setup_environment(vm)
      INITIALIZERS.each { |i| i.arity == 1 ? i.(vm.global_scope) : i.(vm.global_scope, vm) }
    end
  
    def self.register(&bk)
      INITIALIZERS << bk
    end
  
    require File.expand_path("../lib/object.rb", __FILE__)
    Dir.glob File.expand_path("../lib/*.rb", __FILE__) do |f|
      require f
    end
  
    class << self    
      Dir.glob File.expand_path("../lib/*.js", __FILE__) do |f|      
        INITIALIZERS << ->(global_scope, vm) {
          privileged_scope = global_scope.close
          privileged_scope.declare :twostroke_lib_set
          privileged_scope.set_var :twostroke_lib_set, Types::Function.new(->(scope, this, args) {
            vm.lib[Types.to_string(args[0] || Types::Undefined.new).string.intern] = args[1] || Types::Undefined.new
          }, nil, "twostroke_lib_set", [])
          
          parser = Twostroke::Parser.new(Twostroke::Lexer.new(File.read f))
          parser.parse

          compiler = Twostroke::Compiler::TSASM.new parser.statements, "lib_#{f}_"
          compiler.compile

          compiler.bytecode.each do |k,v|
            vm.bytecode[k] = v
          end

          vm.execute :"lib_#{f}_main", privileged_scope
        }
      end
    end
  end
end