class Twostroke::Compiler::Binary
  attr_accessor :bytecode, :ast
  
  def initialize(ast)
    @ast = ast
    @sections = [[]]
    @section_stack = [0]
    @scope_stack = []
  end
  
  def compile
    ast.each &method(:compile_node)
    generate_bytecode
  end
  
  OPCODES = {
    undefined:  0,
    ret:        1,
    pushnum:    2,
    add:        3, 
  }

private

  def generate_bytecode
    @bytecode = "JSX\0"
    # how many sections exist as LE uint32_t:
    bytecode << [@sections.size].pack("L<")
    @sections.map(&method(:generate_bytecode_for_section)).each do |sect|
      bytecode << [sect.size].pack("L<") << sect
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
    @scope_stack.last[var] ||= @scope_stack.last[:ai] += 1
  end
  
  def lookup_var(var)
    @scope_stack.reverse_each.each_with_index do |scope, index|
      return [index, scope[var]] if scope[var]
    end
    nil
  end

  def compile_node(node)
    send type(node), node
  end
  
  def output(*ops)
    ops.each do |op|
      case op
      when Symbol
        raise "unknown op #{op.inspect}" unless OPCODES[op]
        current_section << [OPCODES[op]].pack("L<")
      when Float
        current_section << [op].pack("E")
      else
        raise "bad op type #{op.class.name}"
      end
    end
  end
  
  def type(node)
    node.class.name.split("::").last.intern
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
          compile node.left
          compile node.right
          output op
          if idx, sc = lookup_var(node.left.name)
            output :setvar, idx, sc
          else
            output :setglobal, node.left.name
          end
        elsif type(node.left) == :MemberAccess
          compile node.left.object
          output :dup
          output :member, node.left.member
          compile node.right
          output op
          output :setprop, node.left.member          
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
  
  def Number(node)
    output :pushnum, node.number.to_f
  end
end