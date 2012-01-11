Gem::Specification.new do |s|
  s.name        = "twostroke"
  s.version     = "0.2.2"
  s.authors     = ["Charlie Somerville"]
  s.email       = ["charlie@charliesomerville.com"]
  s.homepage    = "http://github.com/charliesome/twostroke"
  s.summary     = "A Ruby implementation of Javascript"
  s.description = "An implementation of Javascript written in pure Ruby. Twostroke contains a parser, a bytecode compiler, a VM, and a minimal implementation of the Javascript standard library."
  s.files       = Dir["lib/**/*"]
  s.required_ruby_version = ">= 1.9.2"
end