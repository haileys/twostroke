module Twostroke::Compiler
  class CompileError < Twostroke::Error
  end
  
  Dir.glob File.expand_path("../compiler/*", __FILE__) do |f|
    require f
  end
end