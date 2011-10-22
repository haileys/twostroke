module Twostroke
  class Lexer
    RESERVED = %w(function var if instanceof in else for while do this return throw typeof try catch finally void null new delete switch case break default true false)
    TOKENS = [

      [ :MULTI_COMMENT, %r{/\*.*?\*/} ],
      [ :SINGLE_COMMENT, /\/\/.*?$/ ],

      [ :WHITESPACE, /\s+/ ],
      [ :NUMBER, /((?<oct>0[0-7]+)|(?<hex>0x[A-Fa-f0-9]+)|(?<to_f>(\d+(\.?\d*([eE][+-]?\d+)?)?|\.\d+([eE][+-]?\d+)?)))/, ->m do
        method, number = m.names.zip(m.captures).select { |k,v| v }.first
        number.send method
      end ],

      *RESERVED.map do |w|
        [ w.upcase.intern, /#{w}(?=[^a-zA-Z_0-9])/ ]
      end,
      [ :BAREWORD, /[a-zA-Z_\$][\$a-zA-Z_0-9]*/, ->m { m[0] } ],

      [ :STRING, /(["'])((\\.|[^\1])*?[^\1\\]?)\1/, ->m do
        m[2].gsub(/\\([bfnrt])/) { |m|
          case m[1]
          when "b"; "\b"
          when "n"; "\n"
          when "f"; "\f"
          when "r"; "\r"
          when "t"; "\t"
          end
        }
        .gsub(/\\([0-6]{1,3})/) { |m| m[1].to_i(7).chr }
        .gsub(/\\x([a-f0-9]{2})/i) { |m| m[1].to_i(16).chr }
        .gsub(/\\u([a-f0-9]{4})/i) { |m| m[1].to_i(16).chr }
        .gsub(/\\(.)/) { |m| m[1] }
      end ],
      
      [ :REGEXP, %r{/(?<src>(\\.|[^\1])*?[^\1\\]?)/(?<opts>[gim]+)?}, ->m { [m[:src], m[:opts]] } ],

      [ :OPEN_PAREN, /\(/ ],
      [ :CLOSE_PAREN, /\)/ ],
      [ :OPEN_BRACKET, /\[/ ],
      [ :CLOSE_BRACKET, /\]/ ],
      [ :OPEN_BRACE, /\{/ ],
      [ :CLOSE_BRACE, /\}/ ],

      [ :MEMBER_ACCESS, /\./ ],

      [ :INCREMENT, /\+\+/ ],
      [ :DECREMENT, /--/ ],
      [ :PLUS, /\+/ ],
      [ :MINUS, /-/ ],
      [ :ASTERISK, /\*/ ],
      [ :SLASH, /\// ],
      [ :MOD, /%/ ],
      [ :QUESTION, /\?/ ],
      [ :COMMA, /,/ ],
      [ :SEMICOLON, /;/ ],
      [ :COLON, /:/ ],

      [ :AND, /&&/ ],
      [ :AMPERSAND, /&/ ],
      [ :OR, /\|\|/ ],
      [ :PIPE, /\|/ ],
      [ :TRIPLE_EQUALS, /===/ ],
      [ :DOUBLE_EQUALS, /==/ ],
      [ :EQUALS, /=/ ],
      [ :NOT_DOUBLE_EQUALS, /!==/ ],
      [ :NOT_EQUALS, /!=/ ],
      [ :NOT, /!/ ],
      [ :TILDE, /~/ ],
      [ :CARET, /\^/ ],

      [ :LEFT_SHIFT, /<</ ],
      [ :RIGHT_TRIPLE_SHIFT, />>>/ ],
      [ :RIGHT_SHIFT, />>/ ],
      [ :LTE, /<=/ ],
      [ :GTE, />=/ ],
      [ :LT, /</ ],
      [ :GT, />/ ],

    ].map do |a|
      [a[0], Regexp.new("\\A#{a[1].source}", Regexp::MULTILINE), a[2]]
    end
  end
end