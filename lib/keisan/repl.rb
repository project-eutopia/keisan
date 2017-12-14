require "pry"
require "readline"

module Keisan
  class Repl
    COMMANDS = %w(reset quit allow_recursive).freeze

    attr_reader :calculator

    def initialize
      @running = true
      initialize_completion_commands
      reset
    end

    def reset
      @calculator = Keisan::Calculator.new
    end

    def start
      while @running
        command = get_command

        # ctrl-d should break out
        break if command.nil?
        process_command command
      end
    end

    def get_command
      Readline.readline("keisan> ", true)
    end

    def process_command(command)
      command = command.strip
      return if command.empty?

      case command
      when /\Areset\z/i
        reset
      when /\Aquit\z/i
        @running = false
      when /\Aallow_recursive\z/i
        calculator.allow_recursive!
      else
        begin
          output_result calculator.simplify(command)
        rescue StandardError => error
          output_error error
        end
      end
    end

    def output_result(result)
      puts "=> " + CodeRay.encode(result.to_s, :ruby, :terminal)
    end

    def output_error(error)
      puts CodeRay.encode(error.class.to_s, :ruby, :terminal) + ": " + CodeRay.encode("\"#{error.message}\"", :ruby, :terminal)
    end

    private

    def initialize_completion_commands
      completion_proc = Proc.new { |s| COMMANDS.grep(/^#{Regexp.escape(s)}/) }

      Readline.completion_append_character = " "
      Readline.completion_proc = completion_proc
    end
  end
end
