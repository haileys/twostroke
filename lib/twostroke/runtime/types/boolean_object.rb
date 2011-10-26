module Twostroke::Runtime::Types
  class BooleanObject < Object
    def self.constructor_function
      # @TODO
    end
    
    attr_reader :boolean
    def initialize(boolean)
      @boolean = boolean
      super()
    end
    
    def primitive_value
      Boolean.new boolean
    end
  end
end