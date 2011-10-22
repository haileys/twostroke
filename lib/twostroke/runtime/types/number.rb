module Twostroke::Runtime::Types
  class Number < Object
    attr_accessor :number
    
    def initialize(number)
      @number = number
      super
    end
    
    def constructor
      unless @@constructor
        @@constructor ||= Function.new nil, name: "Number" do |this, *args|
          Number.new Types.to_number(args[0])
        end
        proto = Object.new
        @@constructor.set "prototype", proto
      end
      @@constructor
    end
    
    def to_boolean
      !(number.zero? || number.nan?)
    end
    
    def to_number
      number
    end
    
    def to_string
      if number.is_a?(Float) && number.nan?
        "NaN"
      elsif number.zero?
        "0"
      elsif number == Float::INFINITY
        "Infinity"
      else
        number.to_s
      end
    end
  end
end