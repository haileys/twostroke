module Twostroke
  class Lexer
    TOKENS = [

      [ :MULTI_COMMENT, /\/\*.*?\*\// ],
      [ :SINGLE_COMMENT, /\/\/.*?$/ ],

      [ :WHITESPACE, /\s+/ ],
      [ :INTEGER, /\d+/, ->m { m[0].to_i } ],
      [ :FLOAT, /\d*\.\d+/, ->m{ m[0].to_f }],

      *%w(function var if for while do this return throw try catch).map do |w|
        [ w.upcase.intern, /#{w}/ ]
      end,
      [ :BAREWORD, /[a-zA-Z_][a-zA-Z_0-9]*/, ->m { m[0] } ],

      [ :STRING, /(["'])(([^\\]|(\\["'\\bfnrt]|\\[0-6]{1,3}|\\x[a-fA-F0-9]{2}|\\u[a-fA-F0-9]{4}|[^\1])+))\1/, ->m do
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

      [ :OPEN_PAREN, /\(/ ],
      [ :CLOSE_PAREN, /\)/ ],
      [ :OPEN_BRACKET, /\[/ ],
      [ :CLOSE_BRACKET, /\]/ ],
      [ :OPEN_BRACE, /\{/ ],
      [ :CLOSE_BRACE, /\}/ ],

      [ :MEMBER_ACCESS, /\./ ],

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
      [ :NOT_DOUBLE_EQUAL, /!==/ ],
      [ :NOT_EQUAL, /!=/ ],
      [ :NOT, /!/ ],
      [ :TILDE, /~/ ],
      [ :CARET, /\^/ ],

      [ :LTE, /<=/ ],
      [ :GTE, />=/ ],
      [ :LT, /</ ],
      [ :GT, />/ ],

    ].map do |a|
      [a[0], Regexp.new("\\A#{a[1].source}"), a[2]]
    end
  end
end