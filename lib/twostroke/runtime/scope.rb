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
    
    def has_var(var)
      @locals.has_key?(var) || parent.has_var(var)
    end
    
    def declare(var)
      @locals[var] = Types::Undefined.new
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
      @root_object.put root_name.to_s, @root_object
    end
    
    def get_var(var)
      if @root_object.has_own_property var.to_s
        @root_object.get var.to_s
      else
        raise "ReferenceError: undefined variable #{var}" #@TODO
      end
    end
    
    def has_var(var)
      @root_object.has_own_property var.to_s
    end
    
    def declare(var)
    end
    
    def close
      Scope.new self
    end
    
    def set_var(var, value)
      @root_object.put var.to_s, value
    end
    
    def global_scope
      self
    end
  end
end