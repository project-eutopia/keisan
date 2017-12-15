require "pry"
require "readline"

module Keisan
  class Repl
    COMMANDS = %w(
      reset
      quit
      variables
      functions
      allow_recursive
    ).freeze

    attr_reader :calculator

    def initialize
      @running = true
      initialize_completion_commands
      reset
    end

    def reset
      @calculator = Calculator.new
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
      when /\Avariables\z/i
        output_variables
      when /\Afunctions\z/i
        output_functions
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

    def output_variables
      variable_registry.locals.each do |name, variable|
        puts CodeRay.encode("#{name} = #{variable.value}", :ruby, :terminal)
      end
    end

    def output_functions
      function_registry.locals.each do |name, function|
        puts CodeRay.encode("#{name}(#{function.arguments.join(', ')}) = #{function.expression.to_s}", :ruby, :terminal)
      end
    end

    private

    def context
      calculator.context
    end

    def variable_registry
      context.variable_registry
    end

    def function_registry
      context.function_registry
    end

    def initialize_completion_commands
      completion_proc = Proc.new { |s| COMMANDS.grep(/^#{Regexp.escape(s)}/) }

      Readline.completion_append_character = " "
      Readline.completion_proc = completion_proc
    end
  end
end
