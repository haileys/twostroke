module Twostroke::AST
  %w( Addition Subtraction Multiplication Division Modulus
      LeftShift RightArithmeticShift RightLogicalShift
      LessThan LessThanEqual GreaterThan GreaterThanEqual
      In InstanceOf Equality Inequality StrictEquality
      StrictInequality BitwiseAnd BitwiseXor BitwiseOr
      And Or).each do |op|
    klass = Class.new Base do
      attr_accessor :left, :right
    end
    const_set op, klass
  end
end