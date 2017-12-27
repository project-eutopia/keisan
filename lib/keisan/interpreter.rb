module Keisan
  class Interpreter
    attr_reader :calculator

    def initialize(allow_recursive: false)
      @calculator = Calculator.new(allow_recursive: allow_recursive)
    end

    def run(file_name)
      if file_name.nil?
        run_from_stdin
      else
        run_from_file(file_name)
      end
    end

    private

    def run_from_stdin
      run_on_content STDIN.read
    end

    def run_from_file(file_name)
      run_on_content File.open(file_name) do |file|
        file.read
      end
    end

    def run_on_content(content)
      calculator.evaluate(content)
    end
  end
end
