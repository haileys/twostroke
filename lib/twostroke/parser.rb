module Twostroke
  class ParseError < Error
  end
  
  class Parser
    def initialize(tokens)
      @i = -1
      @tokens = tokens
      @statements = []
    end
    
    def parse
      while @i < tokens.length
        statements.push statement
      end
    end
  
  private
    def error!(msg)
      raise ParseError, "at line #{peek.line}, col #{peek.col}. #{msg}"
    end
    def assert_type(tok, *types)
      error! "Found #{tok.type}, expected #{types.join ", "}" unless types.include? tok.type
    end
    def stack
      @stack
    end
    def stack_top
      @stack.last
    end
    def token
      @tokens[@i]
    end
    def next_token
      @i += 1
      token
    end
    def peek_token
      @tokens[@i + 1]
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