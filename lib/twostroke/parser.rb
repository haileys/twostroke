module Twostroke
  class ParseError < Error
  end
  
  class Parser
    attr_reader :statements
    
    def initialize(lexer)
      @i = -1
      @lexer = lexer
      @statements = []
    end
    
    def parse
      while try_peek_token
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
    
    def save_state
      { cur_token: @cur_token, peek_token: @peek_token, lexer_state: @lexer.state }
    end
    def load_state(state)
      @cur_token = state[:cur_token]
      @peek_token = state[:peek_token]
      @lexer.state = state[:lexer_state]
    end
    
    def token
      @cur_token or raise ParseError, "unexpected end of input"
    end
    def next_token(allow_regexp = true)
      @cur_token = @peek_token || @lexer.read_token(allow_regexp)
      @peek_token = nil
      token
    end
    def try_peek_token(allow_regexp = true)
      @peek_token ||= @lexer.read_token(allow_regexp)
    end
    def peek_token(allow_regexp = true)
      @peek_token ||= @lexer.read_token(allow_regexp) or raise ParseError, "unexpected end of input"
    end
    
    ####################
    
    def statement(consume_semicolon = true)
      st = case peek_token.type
      when :RETURN;     send :return
      when :BREAK;      send :break
      when :THROW;      send :throw
      when :VAR;        var
      when :IF;         consume_semicolon = false; send :if
      when :FOR;        consume_semicolon = false; send :for
      when :SWITCH;     consume_semicolon = false; send :switch
      when :DO;         send :do
      when :WHILE;      consume_semicolon = false; send :while
      when :TRY;        consume_semicolon = false; try
      when :OPEN_BRACE; consume_semicolon = false; body
      when :FUNCTION;   consume_semicolon = false; function
      when :SEMICOLON;  nil
      else; expression
      end
      if consume_semicolon
        next_token if try_peek_token && peek_token.type == :SEMICOLON
        #assert_type next_token, :SEMICOLON
      end
      st
    end
   
    def expression(no_comma = false, no_in = false, no_ternary = false)
      expr = expression_after_unary no_comma
      expr = if [:PLUS, :MINUS, :ASTERISK, :SLASH, :MOD,
          :LEFT_SHIFT, :RIGHT_SHIFT, :RIGHT_TRIPLE_SHIFT,
          :AMPERSAND, :CARET, :PIPE ].include? peek_token(false).type
          state = save_state
          next_token
          combined = (peek_token(false).type == :EQUALS)
          load_state state
          if combined
            # combination assignment
            op = next_token(false).type
            assert_type next_token(false), :EQUALS
            AST::UnsortedBinop.operator_class[op].new left: expr, assign_result_left: true, right: expression(true, false, true)
          else
            binop expr
          end
      elsif [ :GT, :LT, :GTE, :LTE, :DOUBLE_EQUALS,
              :TRIPLE_EQUALS, :NOT_EQUALS, :NOT_DOUBLE_EQUALS,
              :AND, :OR, :LEFT_SHIFT, :RIGHT_SHIFT,
              :RIGHT_TRIPLE_SHIFT, :INSTANCEOF,
              *(no_in ? [] : [:IN]) ].include? peek_token(false).type
        expr = binop expr
        # this has a higher precedence than the ternary
        # so we'll hackily check for a ternary after this
        if !no_ternary && try_peek_token && peek_token(false).type == :QUESTION
          ternary(expr)
        else
          expr
        end
      else
        expr
      end
      expr = if peek_token(false).type == :EQUALS
        next_token
        AST::Assignment.new left: expr, right: expression(true)
      elsif !no_ternary && peek_token(false).type == :QUESTION
        ternary(expr)
      else
        expr
      end
      
      if !no_comma && peek_token(false).type == :COMMA
        next_token
        AST::MultiExpression.new left: expr, right: expression
      else
        expr
      end
    end
    
    def expression_after_unary(no_comma = true, no_call = false)
      expr = case peek_token.type
      when :FUNCTION; function
      when :STRING; string
      when :NUMBER; number
      when :REGEXP; regexp
      when :THIS; this
      when :NULL; null
      when :TRUE; send :true
      when :FALSE; send :false
      when :NEW; send :new
      when :DELETE; delete
      when :BAREWORD; bareword
      when :OPEN_PAREN; parens
      when :OPEN_BRACE; object_literal
      when :OPEN_BRACKET; array
      when :NOT; send :not
      when :TILDE; tilde
      when :INCREMENT; pre_increment
      when :DECREMENT; pre_decrement
      when :VOID; void
      when :PLUS; unary_plus
      when :MINUS; unary_minus
      when :TYPEOF; typeof
      else error! "Unexpected #{peek_token.type}"
      end
      loop do
        if !no_call && peek_token(false).type == :OPEN_PAREN
          expr = call expr
        elsif peek_token(false).type == :OPEN_BRACKET
          expr = index expr
        elsif peek_token(false).type == :MEMBER_ACCESS
          expr = member_access expr
        elsif !no_comma && peek_token(false).type == :COMMA
          expr = comma(expr)
        elsif peek_token(false).type == :INCREMENT
          expr = post_increment expr
        elsif peek_token(false).type == :DECREMENT
          expr = post_decrement expr
        else
          return expr
        end
      end
      expr
    end
    
    def binop(left)
      op = next_token.type
      AST::UnsortedBinop.new left: left, op: op, right: expression(true, false, true)
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
    
    def this
      assert_type next_token, :THIS
      AST::This.new
    end
    
    def null
      assert_type next_token, :NULL
      AST::Null.new
    end
    
    def true
      assert_type next_token, :TRUE
      AST::True.new
    end
    
    def false
      assert_type next_token, :FALSE
      AST::False.new
    end
    
    def bareword
      assert_type next_token, :BAREWORD
      AST::Variable.new name: token.val
    end
    
    def ternary(cond)
      assert_type next_token, :QUESTION
      ternary = AST::Ternary.new condition: cond
      ternary.if_true = expression(true)
      assert_type next_token, :COLON
      ternary.if_false = expression(true)
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
      saved_state = save_state
      if next_token.type == :VAR && next_token.type == :BAREWORD && next_token.type == :IN
        for_in = true
        load_state saved_state
      else
        load_state saved_state
        stmt = statement(false) unless peek_token.type == :SEMICOLON
        assert_type next_token, :SEMICOLON, :CLOSE_PAREN
        for_in = (token.type == :CLOSE_PAREN)
      end
      load_state saved_state
      if for_in
        # no luck parsing for(;;), reparse as for(..in..)        
        if peek_token.type == :VAR
          next_token
          assert_type next_token, :BAREWORD
          lval = AST::Declaration.new name: token.val
        else
          lval = expression(false, true)
        end
        assert_type next_token, :IN
        obj = expression
        assert_type next_token, :CLOSE_PAREN
        AST::ForIn.new lval: lval, object: obj, body: statement
      else
        initializer = statement(false) unless peek_token.type == :SEMICOLON
        assert_type next_token, :SEMICOLON
        condition = statement(false) unless peek_token.type == :SEMICOLON
        assert_type next_token, :SEMICOLON
        increment = statement(false) unless peek_token.type == :CLOSE_PAREN
        assert_type next_token, :CLOSE_PAREN
        AST::ForLoop.new initializer: initializer, condition: condition, increment: increment, body: statement
      end
    end
    
    def switch
      assert_type next_token, :SWITCH
      assert_type next_token, :OPEN_PAREN
      sw = AST::Switch.new expression: expression
      assert_type next_token, :CLOSE_PAREN
      assert_type next_token, :OPEN_BRACE
      current_case = nil
      default = false
      while ![:CLOSE_BRACE].include? peek_token.type
        if peek_token.type == :CASE
          assert_type next_token, :CASE
          expr = expression
          node = AST::Case.new expression: expr
          assert_type next_token, :COLON
          sw.cases << node
          current_case = node.statements
        elsif peek_token.type == :DEFAULT
          assert_type next_token, :DEFAULT
          error! "only one default case allowed" if default
          default = true
          node = AST::Case.new
          assert_type next_token, :COLON
          sw.cases << node
          current_case = node.statements
        else
          error! "statements may only appear under a case" if current_case.nil?
          current_case << statement
        end
      end
      assert_type next_token, :CLOSE_BRACE
      sw
    end
    
    def while
      assert_type next_token, :WHILE
      assert_type next_token, :OPEN_PAREN
      node = AST::While.new condition: expression
      assert_type next_token, :CLOSE_PAREN
      node.body = statement
      node
    end
    
    def do
      assert_type next_token, :DO
      node = AST::DoWhile.new body: body
      assert_type next_token, :WHILE
      assert_type next_token, :OPEN_PAREN
      node.condition = expression(false)
      assert_type next_token, :CLOSE_PAREN
      node
    end
    
    def try
      try = AST::Try.new try_statements: []
      assert_type next_token, :TRY
      assert_type next_token, :OPEN_BRACE
      while peek_token.type != :CLOSE_BRACE
        try.try_statements << statement
      end
      assert_type next_token, :CLOSE_BRACE
      assert_type next_token, :CATCH, :FINALLY
      if token.type == :CATCH
        try.catch_statements = []
        assert_type next_token, :OPEN_PAREN
        assert_type next_token, :BAREWORD
        try.catch_variable = token.val
        assert_type next_token, :CLOSE_PAREN
        assert_type next_token, :OPEN_BRACE
        while peek_token.type != :CLOSE_BRACE
          try.catch_statements << statement
        end
        assert_type next_token, :CLOSE_BRACE
      end
      if try_peek_token && peek_token.type == :FINALLY
        try.finally_statements = []
        assert_type next_token, :FINALLY
        assert_type next_token, :OPEN_BRACE
        while peek_token.type != :CLOSE_BRACE
          try.finally_statements << statement
        end
        assert_type next_token, :CLOSE_BRACE
      end
      try
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
    
    def new
      assert_type next_token, :NEW
      node = AST::New.new
      node.callee = expression_after_unary(false, true)
      if try_peek_token && peek_token.type == :OPEN_PAREN
        call = call(node.callee)
        node.arguments = call.arguments
      end
      node
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
      expr = expression unless peek_token.type == :SEMICOLON || peek_token.type == :CLOSE_BRACE
      AST::Return.new expression: expr
    end
    
    def break
      assert_type next_token, :BREAK
      AST::Break.new
    end
    
    def throw
      assert_type next_token, :THROW
      AST::Throw.new expression: expression
    end
    
    def delete
      assert_type next_token, :DELETE
      AST::Delete.new expression: expression
    end
    
    def var
      assert_type next_token, :VAR
      var_rest
    end
    
    def var_rest
      assert_type next_token, :BAREWORD
      decl = AST::Declaration.new(name: token.val)
      return decl if peek_token.type == :SEMICOLON || peek_token.type == :CLOSE_BRACE
      
      assert_type next_token, :COMMA, :EQUALS
      
      if token.type == :COMMA
        AST::MultiExpression.new left: decl, right: var_rest
      else
        assignment = AST::Assignment.new left: decl, right: expression(true)
        if peek_token.type == :SEMICOLON || peek_token.type == :CLOSE_BRACE
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
    
    def regexp
      assert_type next_token, :REGEXP
      AST::Regexp.new regexp: token.val
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
    
    def void
      assert_type next_token, :VOID
      AST::Void.new value: expression_after_unary
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
    
    def pre_increment
      assert_type next_token, :INCREMENT
      AST::PreIncrement.new value: expression_after_unary
    end
    
    def pre_decrement
      assert_type next_token, :DECREMENT
      AST::PreDecrement.new value: expression_after_unary
    end
    
    def typeof
      assert_type next_token, :TYPEOF
      AST::TypeOf.new value: expression_after_unary
    end
  end
end