module Twostroke::Runtime
  class VM    
    attr_accessor :bytecode
    attr_reader :global_scope, :lib
    attr_accessor :line_trace, :instruction_trace
    
    def initialize(bytecode)
      @bytecode = bytecode
      @global_scope = GlobalScope.new self
      @lib = {}
      @name_args = {}
      @vm_eval_counter = 0
    end
    
    def execute(section = :main, scope = nil, this = nil)
      Frame.new(self, section).execute scope, this
    end
    
    def throw_error(type, message)
      throw :exception, lib[type].(nil, global_scope.root_object, [Types::String.new(message)])
    end
    
    def section_name_args(section)
      unless @name_args[section]
        ops = bytecode[section].take_while { |ins,arg| [:".name", :".arg"].include? ins }
        @name_args[section] = [
          ops.select { |ins,arg| :".name" == ins }.map { |ins,arg| arg }.first,
          ops.select { |ins,arg| :".arg" == ins }.map { |ins,arg| arg.to_s }
        ]
      else
        @name_args[section]
      end
    end
    
    def eval(source, scope = nil, this = nil)
      parser = Twostroke::Parser.new Twostroke::Lexer.new source
      parser.parse
      prefix = "#{@vm_eval_counter += 1}_"
      compiler = Twostroke::Compiler::TSASM.new parser.statements, prefix
      compiler.compile
      compiler.bytecode[:"#{prefix}main"][-2] = [:ret]
      if compiler.bytecode[:"#{prefix}main"][-3] == [:pop]
        compiler.bytecode[:"#{prefix}main"][-3] = [:ret]
      end
      bytecode.merge! compiler.bytecode
      execute :"#{prefix}main", scope, this
    end
  
  private
    def error!(msg)
      raise RuntimeError, msg
    end
  end
end