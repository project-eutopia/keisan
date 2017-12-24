module Keisan
  module AST
    class Variable < Literal
      attr_reader :name

      def initialize(name)
        @name = name
      end

      def value(context = nil)
        context = Context.new if context.nil?
        context.variable(name).value(context)
      end

      def unbound_variables(context = nil)
        context ||= Context.new
        context.has_variable?(name) ? Set.new : Set.new([name])
      end

      def ==(other)
        case other
        when Variable
          name == other.name
        else
          false
        end
      end

      def to_s
        name.to_s
      end

      def evaluate(context = nil)
        context ||= Context.new
        if context.has_variable?(name)
          variable = context.variable(name)
          # The variable might just be a variable, i.e. probably in function definition
          if variable.is_a?(Node)
            variable.is_a?(Variable) ? variable : variable.evaluate(context)
          else
            variable
          end
        else
          self
        end
      end

      def simplify(context = nil)
        context ||= Context.new
        if context.has_variable?(name)
          context.variable(name).to_node.simplify(context)
        else
          self
        end
      end

      def replace(variable, replacement)
        if name == variable.name
          replacement
        else
          self
        end
      end

      def differentiate(variable, context = nil)
        context ||= Context.new

        if name == variable.name && !context.has_variable?(name)
          1.to_node
        else
          0.to_node
        end
      end
    end
  end
end
