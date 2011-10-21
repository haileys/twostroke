module Twostroke::Runtime
  class RuntimeError < Twostroke::Error
  end
  
  Dir.glob File.expand_path("../runtime/*", __FILE__) do |f|
    require f
  end
end