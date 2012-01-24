require "bundler/setup"
require "simplecov"
SimpleCov.start

$LOAD_PATH << File.expand_path("../lib", __FILE__)
require "twostroke"
require "paint"

trap("INT") { puts caller; exit! }

class TestCase
  T = Twostroke::Runtime::Types
  
  attr_reader :name, :status, :message
  
  def initialize(name, function, scope)
    @name = name
    @function = function
    @scope = scope
    @assertions = 0
  end
  
  def run
    set_test_helpers
    catch :test_failure do
      ex = catch :exception do
        @function.call @scope, nil, []
        
        if @assertions.zero?
          @status = :error
          @message = "No assertions"
          return false
        end  
        @status = :pass
        return true
      end
      
      @status = :error
      if trace = ex.get("stack") and trace.is_a?(T::String)
        @message = trace.string
      else
        @message = T.to_string(ex).string
      end
    end
    false
  rescue => e
    @status = :error
    @message = ["#{e.class}: #{e.to_s}", *e.backtrace].join "\n"
    false
  end
  
  def fail(message)
    @status = :fail
    @message = message
    throw :test_failure
  end
  
private
  def set_test_helpers
    %w(assert assert_equal).each do |m|
      @scope.set_var m, T::Function.new(->(outer, this, args) {
        send m, *args
        nil
      }, nil, nil, [])
    end
  end

  def assert(condition, message = nil)
    @assertions += 1
    unless T.is_truthy condition
      fail message && T.to_string(message).string
    end
  end
  
  def assert_equal(a, b, message = nil)
    @assertions += 1
    unless T.seq a, b
      msg = "<#{T.to_string(a).string}> !== <#{T.to_string(b).string}>"
      msg << ": #{T.to_string(message).string}" if message
      fail msg
    end
  end
end

class TestFile
  attr_reader :file, :tests
  
  def initialize(file, ctx)
    @file = file
    @ctx = ctx
    @tests = []
    @scope = @ctx.vm.global_scope.close
    setup
  end
  
  def setup
    set_test_helpers
    @ctx.raw_exec File.read(@file), @scope
  end
  
  def run
    tests.each do |test|
      if test.run
        print "."
      elsif test.status == :error
        print "E"
      else
        print "F"
      end
      STDOUT.flush
    end
  end
  
private
  def set_test_helpers
    @scope.set_var "test", Twostroke::Runtime::Types::Function.new(->(outer, this, args) {
      test *args
      nil
    }, nil, nil, [])
  end
  
  def test(name, function)
    name = Twostroke::Runtime::Types.to_string(name).string
    tests << TestCase.new(name, function, @scope)
  end
end

ctx = Twostroke::Context.new

# these are test suites that must be run in an isolated context
isolated_tests = [/mootools/]

files = Dir[File.expand_path("../test/*.js", __FILE__)]
          .sort
          .map { |file| TestFile.new file, ctx }
          .each &:run

results = files.map(&:tests).flatten.map(&:status)
puts "\n\nTests finished - #{results.count :fail} failures and #{results.count :error} errors from #{results.count} test cases\n\n"

files.each do |f|
  f.tests.each do |t|
    next if t.status == :pass
    if t.status == :fail
      print Paint["  FAIL  ", :red]
    else
      print Paint[" ERROR  ", :yellow]
    end
    puts "#{f.file} - #{t.name}"
    puts t.message.lines.map { |l| "        #{l}" } if t.message
    puts
  end
end