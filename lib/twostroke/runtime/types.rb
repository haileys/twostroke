Dir.glob File.expand_path("../types/*", __FILE__) do |f|
  require f
end