module Keisan
  class Token
    attr_reader :string

    def initialize(string)
      raise Exceptions::InvalidToken.new(string) unless string.match(regex)
      @string = string
    end

    def type
      self.class.type
    end

    def self.type
      @type ||= Util.underscore(self.to_s.split("::").last).to_sym
    end

    def regex
      self.class.regex
    end

    def self.regex
      raise Exceptions::NotImplementedError.new(:regex)
    end
  end
end
