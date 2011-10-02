module Twostroke::AST
  class UnsortedBinop < Base
    attr_accessor :left, :op, :right
    
    def self.operator_classes
      @@classes ||= {
        :PLUS => Addition,
        :MINUS => Subtraction
      }
    end
    
    def self.operator_precedence
      @precedences ||= {
        :ASTERISK => 5,
        :SLASH    => 5,
        :MOD      => 5,
        :PLUS     => 6,
        :MINUS    => 6,
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
            
          else
            output.push token
          end
        end
      else
        input
      end
    end
  end
end