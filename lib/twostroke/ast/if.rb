module Twostroke::AST
  class If < Base
    attr_accessor :condition, :then, :else
    
    def collapse
      self.class.new condition: condition.collapse, then: @then.reject(&:nil?).each(:collapse), else: @else.reject(&:nil?).each(:collapse)
    end
  end
end