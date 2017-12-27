module Keisan
  class Interpreter
    attr_reader :calculator

    def initialize(allow_recursive: false)
      @calculator = Calculator.new(allow_recursive: allow_recursive)
    end

    def run(file_name)
      content = File.open(file_name) do |file|
        file.read
      end

      calculator.evaluate(content)
    end
  end
end
