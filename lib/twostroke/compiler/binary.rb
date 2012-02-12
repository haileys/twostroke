class Twostroke::Compiler::Binary
  attr_accessor :bytecode, :ast
  
  def initialize(ast)
    @ast = ast
    @sections = [[]]
    @section_stack = [0]
    @scope_stack = [{}]
    @interned_strings = {}
  end
  
  def compile
    ast.each &method(:hoist)
    ast.each &method(:compile_node)
    output :undefined
    output :ret
    generate_bytecode
  end
  
  OPCODES = {
    undefined:  0,
    ret:        1,
    pushnum:    2,
    add:        3,
    pushglobal: 4,
    pushstr:    5,
    methcall:   6,
    setvar:     7,
    pushvar:    8,
  }

private

  def generate_bytecode
    @bytecode = "JSX\0"
    # how many sections exist as LE uint32_t:
    bytecode << [@sections.size].pack("L<")
    @sections.map(&method(:generate_bytecode_for_section)).each do |sect|
      bytecode << [sect.size].pack("L<") << sect
    end
    bytecode << [@interned_strings.count].pack("L<")
    @interned_strings.each do |str,idx|
      bytecode << [str.bytes.count].pack("L<")
      bytecode << str << "\0"
    end
  end
  
  def generate_bytecode_for_section(section)
    section.join
  end

  def current_section
    @sections[@section_stack.last]
  end

  def push_section
    @section_stack << @sections.size
    @sections << []
    @section_stack.last
  end
  
  def pop_section
    @section_stack.pop
  end
  
  def push_scope
    @scope_stack << { ai: 0 }
  end
  
  def pop_scope
    @scope_stack.pop
  end
  
  def create_local_var(var)
    @scope_stack.last[var] ||= @scope_stack.last.count
  end
  
  def lookup_var(var)
    @scope_stack.reverse_each.each_with_index do |scope, index|
      return [index, scope[var]] if scope[var]
    end
    nil
  end

  def compile_node(node)
    if respond_to? type(node), true
      send type(node), node
    else
      raise "unimplemented node type #{type(node)}"
    end
  end
  
  def intern_string(str)
    @interned_strings[str] ||= @interned_strings.count
  end
  
  def output(*ops)
    ops.each do |op|
      case op
      when Symbol
        raise "unknown op #{op.inspect}" unless OPCODES[op]
        current_section << [OPCODES[op]].pack("L<")
      when Float
        current_section << [op].pack("E")
      when Fixnum
        current_section << [op].pack("L<")
      when String
        current_section << [intern_string(op)].pack("L<")
      else
        raise "bad op type #{op.class.name}"
      end
    end
  end
  
  def type(node)
    node.class.name.split("::").last.intern
  end
  
  def hoist(node)
    node.walk do |node|
      if node.is_a? Twostroke::AST::Declaration
        create_local_var node.name
      elsif node.is_a? Twostroke::AST::Function
        if node.name
          create_local_var node.name
          # because javascript is odd, entire function bodies need to be hoisted, not just their declarations
          Function(node, true)
        end
        false
      else
        true
      end
    end
  end
  
  # ast node compilers
  
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
          compile_node node.left
          compile_node node.right
          output op
          idx, sc = lookup_var node.left.name
          if idx
            output :setvar, idx, sc
          else
            output :setglobal, node.left.name
          end
        elsif type(node.left) == :MemberAccess
          compile_node node.left.object
          output :dup
          output :member, node.left.member
          compile_node node.right
          output op
          output :setprop, node.left.member          
        elsif type(node.left) == :Index
          compile_node node.left.object
          compile_node node.left.index
          output :dup, 2
          output :index
          compile_node node.right
          output op
          output :setindex
        else
          error! "Bad lval in combined operation/assignment"
        end
      else
        compile_node node.left
        compile_node node.right
        output op
      end
    end
    private method
  end
  
  def Variable(node)
    idx, sc = lookup_var node.name
    if idx
      output :pushvar, idx, sc
    else
      output :pushglobal, node.name
    end
  end
  
  def Number(node)
    output :pushnum, node.number.to_f
  end
  
  def String(node)
    output :pushstr, node.string
  end
  
  def Call(node)
    if type(node.callee) == :MemberAccess
      compile_node node.callee.object
      output :pushstr, node.callee.member.to_s
      node.arguments.each { |n| compile_node n }
      output :methcall, node.arguments.size
    elsif type(node.callee) == :Index
      compile_node node.callee.object
      compile_node node.callee.index
      node.arguments.each { |n| compile_node n }
      output :methcall, node.arguments.size
    else
      compile_node node.callee
      node.arguments.each { |n| compile_node n }
      output :call, node.arguments.size
    end
  end
  
  def Declaration(node)
    # no-op
  end
  
  def Assignment(node)
    if type(node.left) == :Variable || type(node.left) == :Declaration
      compile_node node.right
      idx, sc = lookup_var node.left.name
      if idx
        output :setvar, idx, sc
      else
        output :setglobal, node.left.name
      end
    elsif type(node.left) == :MemberAccess
      compile_node node.left.object
      compile_node node.right
      output :setprop, node.left.name
    elsif type(node.left) == :Index
      compile_node node.left.object
      compile_node node.left.index
      compile_node node.right
      output :setindex
    else  
      error! "Bad lval in assignment"
    end
  end
end