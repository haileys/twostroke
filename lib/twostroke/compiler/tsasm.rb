class Twostroke::Compiler::TSASM
  attr_accessor :bytecode, :ast, :prefix
  
  def initialize(ast, prefix = nil)
    @methods = Hash[self.class.private_instance_methods(false).map { |name| [name, true] }]
    @ast = ast
    @prefix = prefix
  end
  
  def compile(node = nil)
    if node
      if node.respond_to? :each
        # hoist named functions to top
        node.select { |n| n.is_a?(Twostroke::AST::Function) && n.name }.each { |n| compile n }
        node.reject { |n| n.is_a?(Twostroke::AST::Function) && n.name }.each { |n| compile n }
      elsif node.is_a? Symbol
        send node
      else
        if @methods[type(node)]
          output :".line", @current_line = node.line if node.line and node.line > @current_line
          @node_stack.push node
          send type(node), node if node
          @node_stack.pop
        else
          error! "#{type node} not implemented"
        end
      end
    else
      @indent = 0
      @bytecode = Hash.new { |h,k| h[k] = [] }
      @current_section = :"#{prefix}main"
      @auto_inc = 0
      @sections = [:"#{prefix}main"]
      @break_stack = []
      @continue_stack = []
      @node_stack = []
      @current_line = 0
            
      ast.each { |node| hoist node }
      ast.each { |node| compile node }
      output :undefined
      output :ret
      
      fix_labels
    end
  end
  
private
  # utility methods
  
  def fix_labels
    bytecode.each do |k,v|
      labels_at = {}
      offset = 0
      v.each_with_index do |ins,i|
        if ins[0] == :".label"
          labels_at[ins[1]] = i + offset
          offset -= 1
        end
      end
      bytecode[k] = v.select do |ins|
        if [:jmp, :jit, :jif, :pushcatch, :pushfinally, :jiee].include?(ins[0])
          ins[1] = labels_at[ins[1]]
        end
        ins[0] != :".label"
      end
    end
  end
  
  def hoist(node)
    node.walk do |node|
      if node.is_a? Twostroke::AST::Declaration
        output :".local", node.name.intern
        false
      elsif node.is_a? Twostroke::AST::Function
        output :".local", node.name.intern if node.name
        # because javascript is odd, entire function bodies need to be hoisted, not just their declarations
        Function(node, true)
        false
      else
        true
      end
    end
  end
  
  def error!(msg)
    raise Twostroke::Compiler::CompileError, "#{msg} at line #{@current_line}"
  end
  
  def type(node)
    node.class.name.split("::").last.intern
  end
  
  def output(*args)
    @bytecode[@current_section] << args
  end
  
  def section(sect)
    @sections.push @current_section
    @current_section = sect
  end
  
  def pop_section
    @current_section = @sections.pop
  end
  
  def uniqid
    @auto_inc += 1
  end
  
  def mutate(left, right)
    if type(left) == :Variable || type(left) == :Declaration
      compile right
      output :set, left.name.intern
    elsif type(left) == :MemberAccess
      compile left.object
      compile right
      output :setprop, left.member.intern
    elsif type(left) == :Index
      compile left.object
      compile left.index
      compile right
      output :setindex
    else
      error! "Bad lval in assignment"
    end
  end
  
  # code generation
  
  { Addition: :add, Subtraction: :sub, Multiplication: :mul, Division: :div,
    Equality: :eq, StrictEquality: :seq, LessThan: :lt, GreaterThan: :gt,
    LessThanEqual: :lte, GreaterThanEqual: :gte, BitwiseAnd: :and,
    BitwiseOr: :or, BitwiseXor: :xor, In: :in, RightArithmeticShift: :sar,
    LeftShift: :sal, RightLogicalShift: :slr, InstanceOf: :instanceof,
    Modulus: :mod
  }.each do |method,op|
    define_method method do |node|
      if node.assign_result_left
        if type(node.left) == :Variable || type(node.left) == :Declaration
          compile node.left
          compile node.right
          output op
          output :set, node.left.name.intern
        elsif type(node.left) == :MemberAccess
          compile node.left.object
          output :dup
          output :member, node.left.member.intern
          compile node.right
          output op
          output :setprop, node.left.member.intern          
        elsif type(node.left) == :Index
          compile node.left.object
          compile node.left.index
          output :dup, 2
          output :index
          compile node.right
          output op
          output :setindex
        else
          error! "Bad lval in combined operation/assignment"
        end
      else
        compile node.left
        compile node.right
        output op
      end
    end
    private method
  end
  def StrictInequality(node)
    StrictEquality(node)
    output :not
  end
  def Inequality(node)
    Equality(node)
    output :not
  end
  
  def post_mutate(left, op)
    if type(left) == :Variable || type(left) == :Declaration
      output :push, left.name.intern
      output :dup
      output op
      output :set, left.name.intern
      output :pop
    elsif type(left) == :MemberAccess
      compile left.object
      output :dup
      output :member, left.member.intern
      output :dup
      output :tst
      output op
      output :setprop, left.member.intern
      output :pop
      output :tld
    elsif type(left) == :Index  
      compile left.object
      compile left.index
      output :dup, 2
      output :index
      output :dup
      output :tst
      output op
      output :setindex
      output :pop
      output :tld
    else
      error! "Bad lval in post-mutation"
    end
  end
  
  def PostIncrement(node)
    post_mutate node.value, :inc
  end
  
  def PostDecrement(node)
    post_mutate node.value, :dec
  end
  
  def pre_mutate(left, op)
    if type(left) == :Variable || type(left) == :Declaration
      output :push, left.name.intern
      output op
      output :set, left.name.intern
    elsif type(left) == :MemberAccess
      compile left.object
      output :dup
      output :member, left.member.intern
      output op
      output :setprop, left.member.intern
    elsif type(left) == :Index
      compile left.object
      compile left.index
      output :dup, 2
      output :index
      output op
      output :setindex
    else
      error! "Bad lval in post-mutation"
    end
  end
  
  def PreIncrement(node)
    pre_mutate node.value, :inc
  end
  
  def PreDecrement(node)
    pre_mutate node.value, :dec
  end
  
  def Call(node)
    if type(node.callee) == :MemberAccess
      compile node.callee.object
      output :dup
      output :member, node.callee.member.intern
      node.arguments.each { |n| compile n }
      output :thiscall, node.arguments.size
    elsif type(node.callee) == :Index
      compile node.callee.object
      output :dup
      compile node.callee.index
      output :index
      node.arguments.each { |n| compile n }
      output :thiscall, node.arguments.size
    else
      compile node.callee
      node.arguments.each { |n| compile n }
      output :call, node.arguments.size
    end
  end
  
  def New(node)
    compile node.callee
    node.arguments.each { |n| compile n }
    output :newcall, node.arguments.size
  end
  
  def Variable(node)
    output :push, node.name.intern
  end
  
  def Null(node)
    output :null
  end
  
  def True(node)
    output :true
  end
  
  def False(node)
    output :false
  end
  
  def Regexp(node)
    output :regexp, node.regexp
  end
  
  def Function(node, in_hoist_stage = false)
    fnid = node.fnid ||= :"#{@prefix}fn_#{uniqid}"
    
    if !node.name or in_hoist_stage
      section fnid
      output :".name", node.name if node.name
      node.arguments.each do |arg|
        output :".arg", arg.intern
      end
      output :".local", node.name.intern if node.name
      node.statements.each { |s| hoist s }
      if node.name
        output :callee
        output :set, node.name.intern
      end
      node.statements.each { |s| compile s }
      output :undefined
      output :ret
      pop_section
      output :close, fnid
      output :set, node.name.intern if node.name
    else  
      output :close, fnid
    end
  end
  
  def Declaration(node)
    # no-op since declarations have already been hoisted
  end
  
  def MultiExpression(node)
    output :pushsp
    compile node.left
    output :popsp
    compile node.right
  end
  
  def Assignment(node)
    mutate node.left, node.right
  end
  
  def String(node)
    output :push, node.string
  end
  
  def Return(node)
    if node.expression
      compile node.expression
    else
      output :undefined
    end
    output :ret
  end
  
  def Delete(node)
    if node.value.is_a?(Twostroke::AST::Variable)
      output :deleteg, node.value.name.intern
    elsif node.value.is_a?(Twostroke::AST::MemberAccess)
      compile node.value.object
      output :delete, node.value.member
    elsif node.value.is_a?(Twostroke::AST::Index)  
      compile node.value.index
      compile node.value.object
      output :deleteindex
    else
      compile node.value
      output :pop
      output :true
    end
  end
  
  def Throw(node)
    compile node.expression
    output :_throw
  end
  
  def Try(node)
    if node.catch_variable
      catch_label = uniqid
      output :pushcatch, catch_label
    end
    finally_label = uniqid
    if node.finally_statements
      output :pushfinally, finally_label
    end
    end_label = uniqid
    compile node.try_statements
    # no exceptions? clean up
    output :popcatch if node.catch_variable
    output :jmp, finally_label
    
    if node.catch_variable
      output :".label", catch_label
      output :".catch", node.catch_variable.intern
      output :popcatch
      compile node.catch_statements
    end
    output :".label", finally_label
    if node.finally_statements
      output :popfinally
      compile node.finally_statements
      output :endfinally
    end
  end
  
  def Or(node)
    compile node.left
    output :dup
    end_label = uniqid
    output :jit, end_label
    output :pop
    compile node.right
    output :".label", end_label
  end
  
  def And(node)
    compile node.left
    output :dup
    end_label = uniqid
    output :jif, end_label
    output :pop
    compile node.right
    output :".label", end_label
  end
  
  def ObjectLiteral(node)
    args = []
    node.items.each do |k,v|
      args << k
      compile v
    end
    output :object, args.map(&:val)
  end
  
  def Array(node)
    node.items.each do |item|
      compile item
    end
    output :array, node.items.size
  end
  
  def While(node)
    start_label = uniqid
    end_label = uniqid
    @continue_stack.push start_label
    @break_stack.push end_label
    output :".label", start_label
    compile node.condition
    output :jif, end_label
    compile node.body
    output :jmp, start_label
    output :".label", end_label
    @continue_stack.pop
    @break_stack.pop
  end
  
  def MemberAccess(node)
    compile node.object
    output :member, node.member.intern
  end
  
  def Index(node)
    compile node.object
    compile node.index
    output :index
  end
  
  def Number(node)
    output :push, node.number
  end
  
  def UnaryPlus(node)
    compile node.value
    output :number
  end
  
  def This(node)
    output :this
  end
  
  def With(node)
    compile node.object
    output :with
    compile node.statement
    output :popscope
  end
  
  def If(node)
    compile node.condition
    else_label = uniqid
    output :jif, else_label
    compile node.then
    if node.else
      end_label = uniqid
      output :jmp, end_label
      output :".label", else_label
      compile node.else
      output :".label", end_label
    else  
      output :".label", else_label
    end
  end
  
  def Ternary(node)
    compile node.condition
    else_label = uniqid
    end_label = uniqid
    output :jif, else_label
    compile node.if_true
    output :jmp, end_label
    output :".label", else_label
    compile node.if_false
    output :".label", end_label
  end
  
  def Switch(node)
    cases = node.cases.map { |c| [uniqid, c] }
    default = cases.select { |l,c| c.expression.nil? }.first
    end_label = uniqid
    compile node.expression
    output :pushsp
    
    @break_stack.push end_label
    
    cases.select { |l,c| c.expression }.each do |label, c|
      output :popsp
      output :pushsp
      output :dup
      compile c.expression
      output :seq
      output :jit, label
    end
    output :popsp # restore sp stack
    output :jmp, (default ? default[0] : end_label)
    
    cases.each do |label, c|
      output :".label", label
      compile c.statements
    end
    
    output :".label", end_label
    @break_stack.pop
  end
  
  def Body(node)
    node.statements.each { |s| compile s }
  end
  
  def DoWhile(node)
    start_label = uniqid
    next_label = uniqid
    end_label = uniqid
    @continue_stack.push next_label
    @break_stack.push end_label
    output :".label", start_label
    compile node.body
    output :".label", next_label
    compile node.condition
    output :jit, start_label
    output :".label", end_label
  end
  
  def ForLoop(node)
    compile node.initializer if node.initializer
    start_label = uniqid
    next_label = uniqid
    end_label = uniqid
    @continue_stack.push next_label
    @break_stack.push end_label
    output :".label", start_label
    compile node.condition if node.condition
    output :jif, end_label
    compile node.body if node.body
    output :".label", next_label
    compile node.increment if node.increment
    output :jmp, start_label
    output :".label", end_label
    @continue_stack.pop
    @break_stack.pop
  end
  
  def _enum_next
    output :enumnext
  end
  
  def ForIn(node)
    end_label = uniqid
    loop_label = uniqid
    @break_stack.push end_label
    @continue_stack.push loop_label
    compile node.object
    output :enum
    output :".label", loop_label
    output :jiee, end_label
    mutate node.lval, :_enum_next
    compile node.body
    output :jmp, loop_label
    output :".label", end_label
    output :popenum
    @break_stack.pop
    @continue_stack.pop
  end
  
  def BinaryNot(node)
    compile node.value
    output :bnot
  end
  
  def Not(node)
    compile node.value
    output :not
  end
  
  def Break(node)
    raise Twostroke::Compiler::CompileError, "Break not allowed outside of loop" unless @break_stack.any?
    output :jmp, @break_stack.last
  end
  
  def Continue(node)
    raise Twostroke::Compiler::CompileError, "Continue not allowed outside of loop" unless @continue_stack.any?
    output :jmp, @continue_stack.last
  end
  
  def TypeOf(node)
    if node.value.is_a?(Twostroke::AST::Variable)
      output :typeof, node.value.name.intern
    else
      compile node.value
      output :typeof
    end
  end
  
  def BracketedExpression(node)
    compile node.value
  end
  
  def Void(node)
    compile node.value
    output :pop
    output :undefined
  end
  
  def Negation(node)
    compile node.value
    output :negate
  end
end