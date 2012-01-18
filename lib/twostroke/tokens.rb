module Twostroke
  class Lexer
    RESERVED = %w(
      function var if instanceof in else for while do this return
        throw typeof try catch finally void null new delete switch
        case break continue default true false with block)
    TOKENS = [

      [ :MULTI_COMMENT, %r{/\*.*?\*/} ],
      [ :SINGLE_COMMENT, /\/\/.*?($|\r|\u2029|\u2028)/ ],

      [ :LINE_TERMINATOR, /[\n\r\u2028\u2029]/ ],
      [ :WHITESPACE, /[ \t\r\v\f]+/ ],
      [ :NUMBER, /((?<oct>0[0-7]+)|(?<hex>0x[A-Fa-f0-9]+)|(?<to_f>(\d+(\.?\d*([eE][+-]?\d+)?)?|\.\d+([eE][+-]?\d+)?)))/, ->m do
        method, number = m.names.zip(m.captures).select { |k,v| v }.first
        n = number.send method
        if (n % 1).zero?
          n.to_i
        else
          n
        end
      end ],

      *RESERVED.map do |w|
        [ w.upcase.intern, /#{w}(?=[^a-zA-Z_0-9])/ ]
      end,
      [ :BAREWORD, /[a-zA-Z_\$][\$a-zA-Z_0-9]*/, ->m { m[0] } ],

      [ :STRING, /(["'])((\\\n|\\.|[^\n\r\u2028\u2029\1])*?[^\1\\]?)\1/, ->m do
        m[2].gsub(/\\(([0-6]{1,3})|u([a-f0-9]{4})|x([a-f0-9]{2})|\n|.)/i) do |m|
          case m
          when /\\([0-6]{1,3})/; m[1..-1].to_i(8).chr "utf-8" 
          when /\\u([a-f0-9]{4})/i; m[2..-1].to_i(16).chr "utf-8"
          when /\\x([a-f0-9]{2})/i; m[2..-1].to_i(16).chr "utf-8"
          else case m[1]
                 when "b"; "\b"
                 when "n"; "\n"
                 when "f"; "\f"
                 when "v"; "\v"
                 when "r"; "\r"
                 when "t"; "\t"
                 when "\n"; ""
                 else; m[1]
               end
          end
        end
      end ],
      
      [ :REGEXP, %r{/(?<src>(\\.|[^\1])*?[^\1\\]?)/(?<opts>[gim]+)?}, ->m { [m[:src], m[:opts]] } ],

      [ :OPEN_PAREN, /\(/ ],
      [ :CLOSE_PAREN, /\)/ ],
      [ :OPEN_BRACKET, /\[/ ],
      [ :CLOSE_BRACKET, /\]/ ],
      [ :OPEN_BRACE, /\{/ ],
      [ :CLOSE_BRACE, /\}/ ],

      [ :MEMBER_ACCESS, /\./ ],

      [ :ADD_EQUALS, /\+=/ ],
      [ :MINUS_EQUALS, /-=/ ],
      [ :TIMES_EQUALS, /\*=/ ], # textmate barfs it's syntax highlighting on this one lol
      [ :DIVIDE_EQUALS, /\/=/ ],
      [ :MOD_EQUALS, /%=/ ],
      [ :LEFT_SHIFT_EQUALS, /<<=/ ],
      [ :RIGHT_TRIPLE_SHIFT_EQUALS, />>>=/ ],
      [ :RIGHT_SHIFT_EQUALS, />>=/ ],
      [ :BITWISE_AND_EQUALS, /&=/ ],
      [ :BITWISE_XOR_EQUALS, /\^=/ ],
      [ :BITWISE_OR_EQUALS, /\|=/ ],

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