module Twostroke::Runtime::Types
  class NumberObject < Object
    def self.constructor_function
      # @TODO
    end
    
    attr_reader :number
    def initialize(number)
      @number = number
      super()
    end
    
    def primitive_value
      Number.new number
    end
  end
end