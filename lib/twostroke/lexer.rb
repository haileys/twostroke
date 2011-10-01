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
    def is?(t)
      if t.is_a? Array
        t.include? type
      else
        t == type
      end
    end
  end
  
  class Lexer
    attr_reader :str, :col, :line, :tokens
    def initialize(str)
      @str = str
      @col = 1
      @line = 1
      @tokens = []
    end
    def lex
      until @str.empty?
        read_token
      end
    end
  private
    def read_token
      TOKENS.each do |token|
        m = token[1].match @str
        if m
          @tokens.push Token.new(:type => token[0], :val => token[2] ? token[2].call(m) : nil, :line => @line, :col => @col) unless [:WHITESPACE, :MULTI_COMMENT, :SINGLE_COMMENT].include? token[0]
          @str = m.post_match
          newlines = m[0].count "\n"
          @col = 1 if !newlines.zero?
          @line += newlines
          @col += m[0].length - (m[0].rindex("\n") || 0)
          return
        end
      end
      raise LexError, "Illegal character '#{@str[0]}' at line #{@line}, col #{@col}. (read #{@tokens.count} tokens)"
    end
  end
end