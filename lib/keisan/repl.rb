require "pry"
require "readline"

module Keisan
  class Repl
    def self.start
      new
    end

    private_class_method :new
    private

    attr_reader :calculator

    def initialize
      reset
      start
    end

    def reset
      @calculator = Keisan::Calculator.new
    end

    def start
      while command = Readline.readline("keisan> ", true)
        command = command.strip
        # Jump to next REPL if empty string
        next if command.empty?

        case command
        when /\Areset\z/i
          reset
        when /\Aquit\z/i
          break
        else
          begin
            result = calculator.simplify(command)
            puts "=> " + CodeRay.encode(result.to_s, :ruby, :terminal)
          rescue StandardError => e
            puts CodeRay.encode(e.class.to_s, :ruby, :terminal) + ": " + CodeRay.encode("\"#{e.message}\"", :ruby, :terminal)
          end
        end
      end
    end
  end
end
