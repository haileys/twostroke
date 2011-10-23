module Twostroke::Runtime
  class Scope
    attr_reader :parent
    
    def initialize(parent = nil)
      @locals = {}
      @parent = parent
    end
    
    def get_var(var)
      if @locals.has_key? var
        @locals[var]
      else
        @parent.get_var(var)
      end
    end
    
    def set_var(var, value)
      if @locals.has_key? var
        @locals[var] = value
      else
        @parent.set_var(var, value)
      end
    end
    
    def declare(var)
      @locals[var] = nil
    end
    
    def close
      Scope.new self
    end
    
    def global_scope
      @global_scope ||= parent.global_scope
    end
  end
  
  class GlobalScope
    attr_reader :root_object, :root_name
    
    def initialize(root_name = "window", root_object = nil)
      @root_name = root_name
      @root_object = root_object || Types::Object.new
      @root_object.set root_name, @root_object
    end
    
    def get_var(var)
      if @root_object.has_own_prop var
        @root_object.get var
      else
        raise "ReferenceError: undefined variable #{var}" #@TODO
      end
    end
    
    def set_var(var, value)
      @root_object.set var, value
    end
    
    def global_scope
      self
    end
  end
end