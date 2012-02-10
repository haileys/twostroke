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
    handler = node.class.name.split("::").last.intern
    send handler, node
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
  
  # ast node compilers
  
  def Addition(node)
    compile_node node.left
    compile_node node.right
    output :add
  end
  
  def Number(node)
    output :pushnum, node.number.to_f
  end
end