class Twostroke::Compiler::TSASM
  attr_accessor :bytecode, :ast
  
  def initialize(ast)
    @methods = Hash[self.class.private_instance_methods(false).map { |name| [name, true] }]
    @ast = ast
  end
  
  def compile(node = nil)
    if node
      if node.respond_to? :each
        # hoist named functions to top
        node.select { |n| n.is_a?(Twostroke::AST::Function) && n.name }.each { |n| compile n }
        node.reject { |n| n.is_a?(Twostroke::AST::Function) && n.name }.each { |n| compile n }
      else
        if @methods[type(node)]
          send type(node), node if node
        else
          error! "#{type node} not implemented"
        end
      end
    else
      @indent = 0
      @bytecode = Hash.new { |h,k| h[k] = [] }
      @current_section = :main
      @auto_inc = 0
      @sections = [:main]
            
      ast.each { |node| hoist node }
      ast.each { |node| compile node }
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
        if [:jmp, :jit, :jif].include?(ins[0])
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
      elsif node.is_a? Twostroke::AST::Function
        output :".local", node.name.intern if node.name
        false
      else
        true
      end
    end
  end
  
  def error!(msg)
    raise Twostroke::Compiler::CompileError, msg
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
  
  def mutate(left)
    if type(left) == :Variable || type(left) == :Declaration
      output :set, left.name.intern
    elsif type(left) == :MemberAccess
      compile left.object
      output :setprop, left.member.intern
    elsif type(left) == :Index  
      compile left.object
      compile left.index
      output :setindex
    else
      error! "Bad lval in assignment"
    end
  end
  
  # code generation
  
  { Addition: :add, Subtraction: :sub, Multiplication: :mul, Division: :div,
    Equality: :eq, StrictEquality: :seq, LessThan: :lt, GreaterThan: :gt,
    LessThanEqual: :lte, GreaterThanEqual: :gte, BitwiseAnd: :and,
    BitwiseOr: :or, BitwiseXor: :xor }.each do |method,op|
    define_method method do |node|
      compile node.left
      compile node.right
      output op
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
      output :tst # Temp STore
      output op
      output :setprop, left.member.intern
      output :tld # Temp LoaD
    elsif type(left) == :Index  
      error! "post-mutatation of array index not supported yet" # @TODO
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
      error! "pre-mutatation of array index not supported yet" # @TODO
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
      output node.callee.index
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
  
  def Function(node)
    fnid = :"fn_#{uniqid}"
    
    section fnid
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
    compile node.right
    mutate node.left
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
  
  def Or(node)
    compile node.left
    output :dup
    end_label = uniqid
    output :jit, end_label
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
    output :object, *args
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
  
  def This(node)
    output :this
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
  
  def Body(node)
    node.statements.each { |s| compile s }
  end
  
  def ForLoop(node)
    compile node.initializer
    start_label = uniqid
    end_label = uniqid
    output :".label", start_label
    compile node.condition
    output :jif, end_label
    compile node.body
    compile node.increment
    output :jmp, start_label
    output :".label", end_label
  end
end