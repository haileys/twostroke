module Twostroke::Runtime::Lib
  INITIALIZERS = []
  
  def self.setup_environment(global_scope)
    INITIALIZERS.each { |i| i.(global_scope) }
  end
  
  def self.register(&bk)
    INITIALIZERS << bk
  end
  
  Dir.glob File.expand_path("../lib/*", __FILE__) do |f|
    require f
  end
end