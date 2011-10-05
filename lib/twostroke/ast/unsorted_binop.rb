module Twostroke::AST
  class UnsortedBinop < Base
    attr_accessor :left, :op, :right
    
    def self.operator_class
      @@classes ||= {
        :ASTERISK           => Multiplication,
        :SLASH              => Division,
        :MOD                => Modulus,
        :PLUS               => Addition,
        :MINUS              => Subtraction,
        :LEFT_SHIFT         => LeftShift,
        :RIGHT_SHIFT        => RightArithmeticShift,
        :RIGHT_TRIPLE_SHIFT => RightLogicalShift,
        :LT                 => LessThan,
        :LTE                => LessThanEqual,
        :GT                 => GreaterThan,
        :GTE                => GreaterThanEqual,
        :IN                 => In,
        :INSTANCE_OF        => InstanceOf,
        :DOUBLE_EQUALS      => Equality,
        :NOT_EQUALS         => Inequality,
        :TRIPLE_EQUALS      => StrictEquality,
        :NOT_DOUBLE_EQUALS  => StrictInequality,
        :AMPERSAND          => BitwiseAnd,
        :CARET              => BitwiseXor,
        :PIPE               => BitwiseOr,
        :AND                => And,
        :OR                 => Or
      }
    end
    
    def self.operator_precedence
      @precedences ||= {
        :ASTERISK           => 5,
        :SLASH              => 5,
        :MOD                => 5,
        :PLUS               => 6,
        :MINUS              => 6,
        :LEFT_SHIFT         => 7,
        :RIGHT_SHIFT        => 7,
        :RIGHT_TRIPLE_SHIFT => 7,
        :LT                 => 8,
        :LTE                => 8,
        :GT                 => 8,
        :GTE                => 8,
        :IN                 => 8,
        :INSTANCE_OF        => 8,
        :DOUBLE_EQUALS      => 9,
        :NOT_EQUALS         => 9,
        :TRIPLE_EQUALS      => 9,
        :NOT_DOUBLE_EQUALS  => 9,
        :AMPERSAND          => 10,
        :CARET              => 11,
        :PIPE               => 12,
        :AND                => 13,
        :OR                 => 14
      }
    end
    
    def collapse(called_by_binop = false)
      left_collapsed = left.is_a?(UnsortedBinop) ? left.collapse(true) : left.collapse
      right_collapsed = right.is_a?(UnsortedBinop) ? right.collapse(true) : right.collapse
      input = [*left_collapsed, op, *right_collapsed]
      
      unless called_by_binop
        stack = []
        output = []
        input.each do |token|
          if token.is_a? Symbol
            while stack.size > 0 && UnsortedBinop.operator_precedence[stack.last] <= UnsortedBinop.operator_precedence[token]
              output.push stack.pop
            end
            stack.push token
          else
            output.push token
          end
        end
        output.push stack.pop until stack.empty?
        
        output.each do |token|
          if token.is_a? Symbol
            r = stack.pop
            l = stack.pop
            stack.push UnsortedBinop.operator_class[token].new(left: l, right: r)
          else
            stack.push token
          end
        end
        
        stack.last
      else
        input
      end
    end
  end
end