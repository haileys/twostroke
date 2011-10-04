module Twostroke::AST
  class Try < Base
    attr_accessor :try_statements, :catch_variable, :catch_statements, :finally_statements
    
    def collapse
      self.class.new try_statements: try_statements.map(&:collapse), catch_variable: catch_variable,
        catch_statements: (catch_statements && catch_statements.map(&:collapse)),
        finally_statements: (finally_statements && finally_statements.map(&:collapse))
    end
  end
end