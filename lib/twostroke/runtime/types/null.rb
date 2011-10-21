module Twostroke::Runtime::Types
  class Null
    def self.null
      @@null ||= new
    end
  end
end