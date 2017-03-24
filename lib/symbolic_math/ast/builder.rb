module SymbolicMath
  module AST
    class Builder
      # Build from parser
      def initialize(string: nil, parser: nil, components: nil)
        if string.nil? && parser.nil? && components.nil?
          raise SymbolicMath::Exceptions::InternalError.new("Require parser or components")
        end

        if string.present?
          @components = SymbolicMath::Parser.new(string: string).components
        elsif parser.present?
          @components = parser.components
        else
          @components = Array.wrap(components)
        end

        @nodes = @components.split {|component|
          component.is_a?(SymbolicMath::Parsing::Operator)
        }.map {|group_of_components|
          node_from_components(group_of_components)
        }
        @operators = @components.select {|component| component.is_a?(SymbolicMath::Parsing::Operator)}

        @priorities = @operators.map(&:priority)

        while @operators.count > 0
          priorities = @operators.map(&:priority)
          max_priority = priorities.uniq.max
          consume_operators_with_priority!(max_priority)
        end

        unless @nodes.count == 1
          raise SymbolicMath::Exceptions::ASTError.new("Should end up with a single node")
        end
      end

      def node
        @nodes.first
      end

      def ast
        node
      end

      private

      def node_from_components(components)
        index_of_unary_components = components.map.with_index {|c,i| [c,i]}.select {|c,i| c.is_a?(SymbolicMath::Parsing::UnaryOperator)}.map(&:last)
        # Must be all in the front
        unless index_of_unary_components.map.with_index.all? {|i,j| i == j}
          raise SymbolicMath::Exceptions::ASTError.new("unary operators must be in front")
        end

        index_of_indexing_components = components.map.with_index {|c,i| [c,i]}.select {|c,i| c.is_a?(SymbolicMath::Parsing::Indexing)}.map(&:last)
        unless index_of_indexing_components.reverse.map.with_index.all? {|i,j| i + j == components.size - 1 }
          raise SymbolicMath::Exceptions::ASTError.new("indexing components must be in back")
        end

        num_unary    = index_of_unary_components.size
        num_indexing = index_of_indexing_components.size

        unless num_unary + 1 + num_indexing == components.size
          raise SymbolicMath::Exceptions::ASTError.new("have too many components")
        end

        unary_components = index_of_unary_components.map {|i| components[i]}
        indexing_components = index_of_indexing_components.map {|i| components[i]}

        node = node_of_component(components[unary_components.size])

        indexing_components.each do |indexing_component|
          node = indexing_component.node_class.new(
            node,
            indexing_component.arguments.map {|parsing_argument|
              Builder.new(components: parsing_argument.components).node
            }
          )
        end

        unary_components.reverse.each do |unary_component|
          node = unary_component.node_class.new(node)
        end

        node
      end

      def node_of_component(component)
        case component
        when SymbolicMath::Parsing::Number
          SymbolicMath::AST::Number.new(component.value)
        when SymbolicMath::Parsing::String
          SymbolicMath::AST::String.new(component.value)
        when SymbolicMath::Parsing::Variable
          SymbolicMath::AST::Variable.new(component.name)
        when SymbolicMath::Parsing::Boolean
          SymbolicMath::AST::Boolean.new(component.value)
        when SymbolicMath::Parsing::List
          SymbolicMath::AST::List.new(
            component.arguments.map {|parsing_argument|
              Builder.new(components: parsing_argument.components).node
            }
          )
        when SymbolicMath::Parsing::Group
          Builder.new(components: component.components).node
        when SymbolicMath::Parsing::Function
          SymbolicMath::AST::Function.new(
            component.arguments.map {|parsing_argument|
              Builder.new(components: parsing_argument.components).node
            },
            component.name
          )
        else
          raise SymbolicMath::Exceptions::ASTError.new("Unhandled component, #{component}")
        end
      end

      def consume_operators_with_priority!(priority)
        # Treat back-to-back operators with same priority as one single call (e.g. 1 + 2 + 3 is add(1,2,3))
        while @operators.any? {|operator| operator.priority == priority}
          next_operator_group = @operators.each.with_index.to_a.split {|operator,i| operator.priority != priority}.select(&:present?).first
          operator_group_indexes = next_operator_group.map(&:last)

          first_index = operator_group_indexes.first
          last_index  = operator_group_indexes.last

          replacement_node = next_operator_group.first.first.node_class.new(
            children = @nodes[first_index..(last_index+1)],
            parsing_operators = @operators[first_index..last_index]
          )

          @nodes.delete_if.with_index {|node, i| i >= first_index && i <= last_index+1}
          @operators.delete_if.with_index {|node, i| i >= first_index && i <= last_index}
          @nodes.insert(first_index, replacement_node)
        end
      end
    end
  end
end
