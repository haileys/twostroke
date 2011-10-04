module Twostroke::AST
  %w( Addition Subtraction Multiplication Division Modulus
      LeftShift RightArithmeticShift RightLogicalShift
      LessThan LessThanEqual GreaterThan GreaterThanEqual
      In InstanceOf Equality Inequality StrictEquality
      StrictInequality BitwiseAnd BitwiseXor BitwiseOr
      And Or).each do |op|
    klass = Class.new Base do
      attr_accessor :left, :right, :assign_result_left
      
      def initialize(*args)
        @assign_result_left = false
        super *args
      end
      
      def collapse
        self.class.new left: left.collapse, right: right.collapse, assign_result_left: assign_result_left
      end
    end
    const_set op, klass
  end
end