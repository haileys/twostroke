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
        node.each { |n| compile n }
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
      output "var #{stack} = [];"
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
    @src << "#{"  " * @indent}#{line}\n"
  end
  
  def stack
    "__stack"
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
    output "#{callee}(#{args});"
  end
  
  def Variable(node)
    output "#{stack}.push(#{node.name});"
  end
  
  def String(node)
    output "#{stack}.push(\"#{node.string.gsub('"', '\\"')}\")"
  end
end