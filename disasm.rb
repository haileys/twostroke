$LOAD_PATH << File.expand_path("../lib", __FILE__)
require "twostroke"

Marshal.load(File.read ARGV.first).each do |section,instructions|
  puts "#{section}:"
  instructions.each_with_index do |ins,offset|
    puts "#{sprintf "%4d", offset}    #{ins[0]}#{" " * (12 - ins[0].size)}#{ins.drop(1).map { |x| x.is_a?(String) ? x.inspect : x }.join ", "}"
  end
end