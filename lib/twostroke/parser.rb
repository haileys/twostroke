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
        st = statement
        statements.push st.collapse if st
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
    def look_ahead(n = 1)
      @tokens[@i + n]
    end
    
    ####################
    
    def statement(consume_semicolon = true)
      st = case peek_token.type
      when :RETURN;     send :return
      when :VAR;        var
      when :IF;         consume_semicolon = false; send :if
      when :FOR;        consume_semicolon = false; send :for
      when :OPEN_BRACE; consume_semicolon = false; body
      when :SEMICOLON;  nil
      else; expression
      end
      if consume_semicolon
        #next_token if try_peek_token && peek_token.type == :SEMICOLON
        assert_type next_token, :SEMICOLON
      end
      st
    end
    
    def expression(no_comma = false, no_in = false)
      expr = expression_after_unary no_comma
      if [:PLUS, :MINUS, :ASTERISK, :SLASH, :GT, :LT,
          :GTE, :LTE, :DOUBLE_EQUALS, :TRIPLE_EQUALS,
          :NOT_EQUALS, :NOT_DOUBLE_EQUALS, :AND, :OR,
          :AMPERSAND, :PIPE, :CARET, :MOD, :LEFT_SHIFT,
          :RIGHT_SHIFT, :RIGHT_TRIPLE_SHIFT, :INSTANCEOF,
          *(no_in ? [] : [:IN]) ].include? peek_token.type
        binop expr
      elsif peek_token.type == :EQUALS
        next_token
        AST::Assignment.new left: expr, right: expression(no_comma)
      elsif peek_token.type == :QUESTION
        ternary(expr)
      else
        expr
      end
    end
    
    def expression_after_unary(no_comma = false)
      expr = case peek_token.type
      when :FUNCTION; function
      when :STRING; string
      when :NUMBER; number
      when :BAREWORD; bareword
      when :OPEN_PAREN; parens
      when :OPEN_BRACE; object_literal
      when :OPEN_BRACKET; array
      when :NOT; send :not
      when :TILDE; tilde
      when :INCREMENT; pre_increment
      when :DECREMENT; pre_decrement
      when :PLUS; unary_plus
      when :MINUS; unary_minus
      when :TYPEOF; typeof
      else error! "Unexpected #{peek_token.type}"
      end
      loop do
        if peek_token.type == :OPEN_PAREN
          expr = call expr
        elsif peek_token.type == :OPEN_BRACKET
          expr = index expr
        elsif peek_token.type == :MEMBER_ACCESS
          expr = member_access expr
        elsif !no_comma && peek_token.type == :COMMA
          expr = comma(expr)
        elsif peek_token.type == :INCREMENT
          expr = post_increment expr
        elsif peek_token.type == :DECREMENT
          expr = post_decrement expr
        else
          return expr
        end
      end
      expr
    end
    
    def binop(left)
      next_token
      AST::UnsortedBinop.new left: left, op: token.type, right: expression
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
      AST::Variable.new name: token.val
    end
    
    def ternary(cond)
      assert_type next_token, :QUESTION
      ternary = AST::Ternary.new condition: cond
      ternary.if_true = expression
      assert_type next_token, :COLON
      ternary.if_false = expression
      ternary
    end
    
    def if
      assert_type next_token, :IF
      assert_type next_token, :OPEN_PAREN
      node = AST::If.new condition: expression
      assert_type next_token, :CLOSE_PAREN
      node.then = statement
      if try_peek_token && peek_token.type == :ELSE
        assert_type next_token, :ELSE
        node.else = statement
      end
      node
    end
    
    def for
      assert_type next_token, :FOR
      assert_type next_token, :OPEN_PAREN
      # decide if this is a for(... in ...) or a for(;;) loop
      saved_i = @i
      stmt = statement(false)
      assert_type next_token, :SEMICOLON, :CLOSE_PAREN
      if token.type == :CLOSE_PAREN
        @i = saved_i # no luck parsing for(;;), reparse as for(..in..)
        lval = expression(false, true)
        assert_type next_token, :IN
        obj = expression
        assert_type next_token, :CLOSE_PAREN
        AST::ForIn.new lval: lval, object: obj, body: statement
      else
        initializer = stmt
        condition = statement(false)
        assert_type next_token, :SEMICOLON
        increment = statement(false)
        assert_type next_token, :CLOSE_PAREN
        AST::ForLoop.new initializer: initializer, condition: condition, increment: increment, body: statement
      end
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
        c.arguments.push expression(true)
        if peek_token.type == :COMMA
          next_token
          redo
        end
      end
      next_token
      c
    end
    
    def index(obj)
      assert_type next_token, :OPEN_BRACKET
      ind = expression
      assert_type next_token, :CLOSE_BRACKET
      AST::Index.new object: obj, index: ind
    end
    
    def return
      assert_type next_token, :RETURN
      AST::Return.new expression: expression
    end
    
    def var
      assert_type next_token, :VAR
      var_rest
    end
    
    def var_rest
      assert_type next_token, :BAREWORD
      decl = AST::Declaration.new(name: token.val)
      return decl if peek_token.type == :SEMICOLON
      
      assert_type next_token, :COMMA, :EQUALS
      
      if token.type == :COMMA
        AST::MultiExpression.new left: decl, right: var_rest
      else
        assignment = AST::Assignment.new left: decl, right: expression(true)
        if peek_token.type == :SEMICOLON
          assignment
        elsif peek_token.type == :COMMA
          next_token
          AST::MultiExpression.new left: assignment, right: var_rest
        else
          error! "Unexpected #{peek_token.type}"
        end
      end
    end
    
    def assignment(lval)
      assert_type next_token, :EQUALS
      AST::Assignment.new left: lval, right: expression
    end
    
    def comma(left)
      assert_type next_token, :COMMA
      AST::MultiExpression.new left: left, right: expression
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
        obj.items.push [key, expression(true)]
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
        ary.items.push expression(true)
        if peek_token.type == :COMMA
          next_token
          redo
        end
      end
      next_token
      ary
    end
    
    def parens
      assert_type next_token, :OPEN_PAREN
      expr = expression
      assert_type next_token, :CLOSE_PAREN
      expr
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
    
    def not
      assert_type next_token, :NOT
      AST::Not.new value: expression_after_unary
    end
    
    def tilde
      assert_type next_token, :TILDE
      AST::BinaryNot.new value: expression_after_unary
    end
    
    def unary_plus
      assert_type next_token, :PLUS
      AST::UnaryPlus.new value: expression_after_unary
    end
    
    def unary_minus
      assert_type next_token, :MINUS
      AST::Negation.new value: expression_after_unary
    end
    
    def post_increment(obj)
      assert_type next_token, :INCREMENT
      AST::PostIncrement.new value: obj
    end
    
    def post_decrement(obj)
      assert_type next_token, :DECREMENT
      AST::PostDecrement.new value: obj
    end
    
    def pre_increment(obj)
      assert_type next_token, :INCREMENT
      AST::PreIncrement.new value: obj
    end
    
    def pre_decrement(obj)
      assert_type next_token, :DECREMENT
      AST::PreDecrement.new value: obj
    end
    
    def typeof
      assert_type next_token, :TYPEOF
      AST::TypeOf.new value: expression_after_unary
    end
  end
end