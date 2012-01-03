module Twostroke::AST
  class Try < Base
    attr_accessor :try_statements, :catch_variable, :catch_statements, :finally_statements
    
    def collapse
      self.class.new try_statements: try_statements.reject(&:nil?).map(&:collapse), catch_variable: catch_variable,
        catch_statements: (catch_statements && catch_statements.reject(&:nil?).map(&:collapse)),
        finally_statements: (finally_statements && finally_statements.reject(&:nil?).map(&:collapse))
    end
    
    def walk(&bk)
      if yield self
        try_statements.each { |s| s.walk &bk }
        catch_statements.each { |s| s.walk &bk } if catch_statements
        finally_statements.each { |s| s.walk &bk } if finally_statements
      end
    end
  end
end