module Twostroke
  class LexError < Twostroke::Error
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
    attr_accessor :str, :col, :line
    
    def state
      { str: str, col: col, line: line }
    end
    def state=(state)
      @str = state[:str]
      @col = state[:col]
      @line = state[:line]
    end
    
    def initialize(str)
      @str = str
      @col = 1
      @line = 1
      @line_terminator = false
    end
    
    def read_token(allow_regexp = true)
      TOKENS.select { |t| allow_regexp || t[0] != :REGEXP }.each do |token|
        m = token[1].match @str
        if m
          tok = Token.new(:type => token[0], :val => token[2] ? token[2].call(m) : nil, :line => @line, :col => @col)
          @str = m.post_match
          newlines = m[0].count "\n"
          @col = 1 if !newlines.zero?
          @line += newlines
          @col += m[0].length - (m[0].rindex("\n") || 0)
          if token[0] == :LINE_TERMINATOR or [:WHITESPACE, :MULTI_COMMENT, :SINGLE_COMMENT].include? token[0]
            return read_token(allow_regexp)
          else
            return tok
          end
        end
      end
      if @str.size > 0
        raise LexError, "Illegal character '#{@str[0]}' at line #{@line}, col #{@col}."
      else
        nil
      end
    end
  end
end