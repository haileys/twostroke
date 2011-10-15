class Twostroke::Compiler
  class CompileError < Twostroke::Error
  end
  
  attr_accessor :src, :ast
  
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
      @src = ""
      prologue
      ast.each { |node| compile node }
    end
  end
  
private
  # utility methods
  
  def error!(msg)
    raise CompileError, msg
  end
  
  def type(node)
    node.class.name.split("::").last.intern
  end
  
  def indent
    @indent += 1
  end
  
  def dedent
    @indent -= 1
  end
  
  def output(line)
    @src << "#{"\t" * @indent}#{line}\n"
  end
  
  def stack
    "__stack"
  end
  
  def prologue
    output "var #{stack} = [], #{stack}_sizes = [], __tmp;"
  end
  
  def binop(op, node)
    if node.assign_result_left
      compile node.right
      mutate node.left, "%s #{op}= #{stack}.pop()"
    else
      compile node.right
      compile node.left
      output "#{stack}.push(#{stack}.pop() #{op} #{stack}.pop());"
    end
  end
  
  def escape(str)
    "\"#{str.gsub("\\","\\\\").gsub('"','\\"').gsub(/[^\x20-\x7e]/) { |m| "\\x#{m.ord.to_s 16}" } }\""
  end
  
  def mutate(left, fmt)
    lval = nil
    if type(left) == :Variable
      lval = "#{left.name}"
    elsif type(left) == :Declaration
      compile left
      lval = "#{left.name}"
    elsif type(left) == :MemberAccess
      compile left.object
      lval = "#{stack}.pop().#{left.member}"
    elsif type(left) == :Index
      compile left.index
      compile left.object
      lval = "#{stack}.pop()[#{stack}.pop()]"
    else
      error! "Invalid left hand side in assignment"
    end
    output "#{stack}.push(#{sprintf(fmt, lval)});"
  end
  
  # code generation methods
  
  def Call(node)
    compile node.arguments.reverse_each 
    callee = nil
    if type(node.callee) == :MemberAccess
      compile node.callee.object
      callee = "#{stack}.pop().#{node.callee.member}"
    elsif type(node.callee) == :Index
      compile node.callee.index
      compile node.callee.object
      callee = "#{stack}.pop()[#{stack}.pop()]"
    else
      compile node.callee
      callee = "#{stack}.pop()"
    end
    args = (["#{stack}.pop()"] * node.arguments.size).join ", "
    output "#{stack}.push(#{callee}(#{args}));"
  end
  
  def Variable(node)
    output "#{stack}.push(#{node.name});"
  end
  
  def String(node)
    output "#{stack}.push(#{escape node.string});"
  end
  
  def MultiExpression(node)
    output "#{stack}_sizes.push(#{stack}.length);"
    compile node.left
    output "#{stack}.length = #{stack}_sizes.pop();" # so we don't unbalance the stack
    compile node.right
  end
  
  def Declaration(node)
    output "var #{node.name};"
  end
  
  def Assignment(node)
    compile node.right
    mutate node.left, "%s = #{stack}.pop()"
  end
  
  def Function(node)
    if node.name
      output "function #{node.name}(#{node.arguments.join ", "}) {"
    else
      output "#{stack}.push(function(#{node.arguments.join ", "}) {"
    end
    indent
    prologue
    compile node.statements
    dedent
    if node.name
      output "}"
      output "#{stack}.push(#{node.name});"
    else
      output "});"
    end
  end
  
  def Return(node)
    compile node.expression
    output "return #{stack}.pop();"
  end
  
  def Addition(node);         binop "+", node; end
  def Subtraction(node);      binop "-", node; end
  def Multiplication(node);   binop "*", node; end
  def Division(node);         binop "/", node; end
  def Equality(node);         binop "==", node; end
  def Inequality(node);       binop "!=", node; end
  def StrictEquality(node);   binop "===", node; end
  def StrictInequality(node); binop "!==", node; end
  def LessThan(node);         binop "<", node; end
  def LessThanEqual(node);    binop "<=", node; end
  def GreaterThan(node);      binop ">", node; end
  def GreaterThanEqual(node); binop ">=", node; end
  
  def And(node)
    compile node.left
    output "if(#{stack}[#{stack}.length - 1]) {"
    indent
    compile node.right
    dedent
    output "}"
  end
  def Or(node)
    compile node.left
    output "if(!#{stack}[#{stack}.length - 1]) {"
    indent
    compile node.right
    dedent
    output "}"
  end
  
  def If(node)
    compile node.condition
    output "if(#{stack}.pop()) {"
    indent
    compile node.then
    dedent
    output "} else {"
    indent
    compile node.else if node.else
    dedent
    output "}"
  end
  
  def Null(node)
    output "#{stack}.push(null);"
  end
  
  def This(node)
    output "#{stack}.push(this);"
  end
  
  def Array(node)
    compile node.items.reverse
    args = ["#{stack}.pop()"] * node.items.size
    output "#{stack}.push([#{args.join ", "}]);"
  end
  
  def ObjectLiteral(node)
    compile node.items.map(&:last).reverse
    keys = []
    node.items.each do |k,v|
      keys << "#{escape k.val}: #{stack}.pop()"
    end
    output "#{stack}.push({ #{keys.join ", "} });"
  end
  
  def Number(node)
    output "#{stack}.push(#{node.number});"
  end
  
  def Index(node)
    compile node.index
    compile node.object
    output "#{stack}.push(#{stack}.pop()[#{stack}.pop()]);"
  end
  
  def Negation(node)
    compile node.value
    output "#{stack}.push(-#{stack}.pop());"
  end
  
  def Not(node)
    compile node.value
    output "#{stack}.push(!#{stack}.pop());"
  end
  
  def Body(node)
    compile node.statements
  end
  
  def Ternary(node)
    compile node.condition
    output "if(#{stack}.pop()) {"
    indent
    compile node.if_true
    dedent
    output "} else {"
    indent
    compile node.if_false
    dedent
    output "}"
  end
  
  def MemberAccess(node)
    compile node.object
    output "#{stack}.push(#{stack}.pop().#{node.member});"
  end
  
  def ForLoop(node)
    compile node.initializer
    output "while(true) {"
    indent
    compile node.condition
    output "if(!#{stack}.pop()) break;"
    compile node.body
    compile node.increment
    dedent
    output "}"
  end
  
  def ForIn(node)
    compile node.object
    output "for(var __tmp_lval in #{stack}.pop()) {"
    indent
    mutate node.lval, "%s = __tmp_lval"
    compile node.body
    dedent
    output "}"
  end
  
  def PostIncrement(node)
    mutate node.value, "%s++"
  end
  def PostDecrement(node)
    mutate node.value, "%s--"
  end
  def PreIncrement(node)
    mutate node.value, "++%s"
  end
  def PreDecrement(node)
    mutate node.value, "--%s"
  end
  
  def While(node)
    output "while(true) {"
    indent
    compile node.condition
    output "if(!#{stack}.pop()) break;"
    compile node.body
    dedent
    output "}"
  end
  
  def Try(node)
    output "try {"
    indent
    compile node.try_statements
    dedent
    if node.catch_variable
      output "} catch(#{node.catch_variable}) {"
      indent
      compile node.catch_statements
      dedent
    end
    if node.finally_statements
      output "} finally {"
      indent
      compile node.finally_statements
      dedent
    end
    output "}"
  end
  
  def Void(node)
    compile node.value
    output "#{stack}.push(void #{stack}.pop());"
  end
  
  def TypeOf(node)
    puts type(node.value)
    if type(node.value) == :VARIABLE
      output "#{stack}.push(typeof #{node.value.name});"
    else
      compile node.value
      output "#{stack}.push(typeof #{stack}.pop());"
    end
  end
  
  def New(node)
    compile node.arguments.reverse
    compile node.callee
    args = ["#{stack}.pop()"] * node.arguments.size
    output "__tmp = #{stack}.pop();"
    output "#{stack}.push(new __tmp(#{args.join ", "}));"
  end
end
