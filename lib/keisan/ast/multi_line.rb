module Keisan
  module AST
    class MultiLine < Parent
      def value(context = nil)
        context ||= Context.new
        evaluate(context).value(context)
      end

      def evaluate_assignments(context = nil)
        self
      end

      def evaluate(context = nil)
        context ||= Context.new
        @children = children.map {|child| child.evaluate(context)}
        @children.last
      end

      def simplify(context = nil)
        evaluate(context)
      end

      def to_s
        children.map(&:to_s).join(";")
      end

      def unbound_variables(context = nil)
        context ||= Context.new
        unbound_variables = Set.new
        defined_variables = Set.new
        children.each do |child|
          if child.is_a?(Assignment) && child.is_variable_definition?
            variable = child.children.first
            value = child.children.last
            defined_variables.add(variable.name) unless variable == value
          end
          unbound_variables |= child.unbound_variables(context) - defined_variables
        end
        unbound_variables
      end
    end
  end
end
