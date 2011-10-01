module Twostroke
  class ParseError < Error
  end
  
  class Parser
    attr_reader :statements
    
    def initialize(tokens)
      @i = -1
      @tokens = tokens + [Token.new(type: :SEMICOLON)]
      @statements = []
    end
    
    def parse
      while @i + 1 < @tokens.length
        statements.push statement
      end
    end
  
  private
    def error!(msg)
      raise ParseError, "Syntax error at line #{token.line}, col #{token.col}. #{msg}"
    end
    def assert_type(tok, *types)
      error! "Found #{tok.type}#{"<#{tok.val}>" if tok.val}, expected #{types.join ", "}" unless types.include? tok.type
    end
    def stack
      @stack
    end
    def stack_top
      @stack.last
    end
    def token
      @tokens[@i] or raise ParseError, "unexpected end of input"
    end
    def next_token
      @i += 1
      token
    end
    def try_peek_token
      @i + 1 < @tokens.length ? peek_token : nil
    end
    def peek_token
      @tokens[@i + 1] or raise ParseError, "unexpected end of input"
    end
  
    ####################
    
    def statement
      st = case peek_token.type
      when :RETURN; send :return
      when :VAR; var
      when :IF; send :if
      when :OPEN_BRACE; body
      when :SEMICOLON; nil
      else; expression
      end
      next_token if try_peek_token && peek_token.type == :SEMICOLON
      st
    end
    
    def expression
      expr = case peek_token.type
      when :FUNCTION; function
      when :STRING; string
      when :NUMBER; number
      when :BAREWORD; bareword
      when :OPEN_BRACE; object_literal
      when :OPEN_BRACKET; array
      else error! "Unexpected #{peek_token.type}"
      end
      if [:PLUS, :MINUS, :ASTERISK, :SLASH, :GT, :LT,
          :GTE, :LTE, :DOUBLE_EQUALS, :TRIPLE_EQUALS,
          :NOT_EQUALS, :NOT_DOUBLE_EQUALS, :AND, :OR,
          :AMPERSAND, :PIPE, :TILDE, :CARET, :MOD   ].include? peek_token.type
        op = next_token.type
        AST::UnsortedBinop.new left: expr, op: op, right: expression
      else
        expr
      end
    end
    
    def body
      assert_type next_token, :OPEN_BRACE
      body = AST::Body.new
      while peek_token.type != :CLOSE_BRACE
        body.statements.push statement
      end
      assert_type next_token, :CLOSE_BRACE
      body
    end
    
    def bareword
      assert_type next_token, :BAREWORD
      var = AST::Variable.new name: token.val
      if peek_token.type == :OPEN_PAREN
        call var
      elsif peek_token.type == :MEMBER_ACCESS
        member_access var
      else
        var
      end
    end
    
    def if
      assert_type next_token, :IF
      assert_type next_token, :OPEN_PAREN
      node = AST::If.new condition: expression
      assert_type next_token, :CLOSE_PAREN
      node.then = body
      if try_peek_token && peek_token.type == :ELSE
        assert_type next_token, :ELSE
        node.else = body
      end
      node
    end
    
    def member_access(obj)
      assert_type next_token, :MEMBER_ACCESS
      assert_type next_token, :BAREWORD
      access = AST::MemberAccess.new object: obj, member: token.val
      if peek_token.type == :MEMBER_ACCESS
        member_access access
      elsif peek_token.type == :OPEN_PAREN
        call access
      elsif peek_token.type == :EQUALS
        assignment access
      else
        access
      end
    end
    
    def call(callee)
      assert_type next_token, :OPEN_PAREN
      c = AST::Call.new callee: callee
      while peek_token.type != :CLOSE_PAREN
        c.arguments.push expression
        if peek_token.type == :COMMA
          next_token
          redo
        end
      end
      next_token
      c
    end
    
    def return
      assert_type next_token, :RETURN
      AST::Return.new expression: expression
    end
    
    def var
      assert_type next_token, :VAR
      assert_type next_token, :BAREWORD
      decl = AST::Declaration.new(name: token.val)
      return decl if peek_token.type == :SEMICOLON
      assert_type next_token, :EQUALS
      AST::Assignment.new left: decl, right: expression
    end
    
    def assignment(lval)
      assert_type next_token, :EQUALS
      AST::Assignment.new left: lval, right: expression
    end
    
    def number
      assert_type next_token, :NUMBER
      AST::Number.new number: token.val
    end
    
    def string
      assert_type next_token, :STRING
      AST::String.new string: token.val
    end
    
    def object_literal
      assert_type next_token, :OPEN_BRACE
      obj = AST::ObjectLiteral.new
      while peek_token.type != :CLOSE_BRACE
        assert_type next_token, :BAREWORD, :STRING, :NUMBER
        key = token
        assert_type next_token, :COLON
        obj.items.push [key, expression]
        if peek_token.type == :COMMA
          next_token
          redo
        end
      end
      next_token
      obj
    end
    
    def array
      assert_type next_token, :OPEN_BRACKET
      ary = AST::Array.new
      while peek_token.type != :CLOSE_BRACKET
        ary.items.push expression
        if peek_token.type == :COMMA
          next_token
          redo
        end
      end
      next_token
      ary
    end
    
    def function
      assert_type next_token, :FUNCTION
      fn = AST::Function.new arguments: [], statements: []
      error! unless [:BAREWORD, :OPEN_PAREN].include? next_token.type
      if token.type == :BAREWORD
        fn.name = token.val
        assert_type next_token, :OPEN_PAREN
      end
      while peek_token.type == :BAREWORD
        fn.arguments.push next_token.val
        next_token if peek_token.type == :COMMA
      end
      assert_type next_token, :CLOSE_PAREN
      assert_type next_token, :OPEN_BRACE
      while peek_token.type != :CLOSE_BRACE
        fn.statements.push statement
      end
      assert_type next_token, :CLOSE_BRACE
      fn
    end
  end
end