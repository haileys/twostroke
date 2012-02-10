module Twostroke
  class LexError < SyntaxError
  end
  
  class Token
    attr_accessor :type, :val, :line, :col
    def initialize(hash = {})
      hash.each do |k,v|
        send "#{k}=", v
      end
    end
  end
  
  class Lexer
    attr_accessor :str, :offset, :col, :line, :restricted
    
    def state
      { str: str, col: col, line: line, offset: offset, restricted: restricted }
    end
    
    def state=(state)
      @str = state[:str]
      @offset = state[:offset]
      @col = state[:col]
      @line = state[:line]
      @restricted = state[:restricted]
    end
    
    def initialize(str)
      @str = str
      @offset = 0
      @col = 1
      @line = 1
      @line_terminator = false
      @restricted = false
    end
    
    def restrict
      @restricted = true
      retn = yield
      @restricted = false
      retn
    end
    
    def read_token(allow_regexp = true)
      TOKENS.select { |t| allow_regexp || t[0] != :REGEXP }.each do |token|
        m = token[1].match @str, @offset
        if m
          tok = Token.new(:type => token[0], :val => token[2] ? token[2].call(m) : nil, :line => @line, :col => @col)
          @offset += m[0].size
          newlines = m[0].count "\n"
          @col = 1 if !newlines.zero?
          @line += newlines
          @col += m[0].length - (m[0].rindex("\n") || 0)
          if [:WHITESPACE, :MULTI_COMMENT, :SINGLE_COMMENT].include?(token[0]) or (!restricted && token[0] == :LINE_TERMINATOR)
            return read_token(allow_regexp)
          else
            return tok
          end
        end
      end
      if @offset < @str.size
        raise LexError, "Illegal character '#{@str[0]}' at line #{@line}, col #{@col}."
      else
        nil
      end
    end
  end
end