module Twostroke::AST
  [ :PostIncrement, :PreIncrement, :PostDecrement, :PreDecrement,
    :BinaryNot, :UnaryPlus, :Negation, :TypeOf, :Not, :Void ].each do |op|
      klass = Class.new Base do
        attr_accessor :value
      
        def collapse
          self.class.new value: value.collapse
        end
        
        def walk(&bk)
          if yield self
            value.walk &bk
          end
        end
      end
      const_set op, klass
    end
end