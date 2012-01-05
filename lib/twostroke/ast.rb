module Twostroke
  module AST
    class Base
      attr_accessor :line
      def initialize(hash = {})
        hash.each do |k,v|
          send "#{k}=", v
        end
      end
    end
    
    Dir.glob File.expand_path("../ast/*", __FILE__) do |f|
      require f
    end
  end
end