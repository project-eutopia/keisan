module Keisan
  module AST
    class LineBuilder
      # Build from parser
      def initialize(components)
        @components = components
        @nodes = components_to_basic_nodes(@components)

        # Negative means not an operator
        @priorities = @nodes.map {|node| node.is_a?(Keisan::Parsing::Operator) ? node.priority : -1}

        consume_operators!

        case @nodes.count
        when 0
          # Empty string, set to just Null
          @nodes = [Keisan::AST::Null.new]
        when 1
          # Good
        else
          raise Keisan::Exceptions::ASTError.new("Should end up with a single node")
        end
      end

      def node
        @nodes.first
      end

      def ast
        node
      end

      private

      # Array of AST elements, and Parsing operators
      def components_to_basic_nodes(components)
        nodes_components = []

        components.each do |component|
          if component.is_a?(Keisan::Parsing::LineSeparator)
            nodes_components << [component]
          elsif nodes_components.empty? || nodes_components.last.last.is_a?(Keisan::Parsing::LineSeparator)
            nodes_components << [component]
          else
            is_operator = [nodes_components.last.last.is_a?(Keisan::Parsing::Operator), component.is_a?(Keisan::Parsing::Operator)]

            if is_operator.first == is_operator.last
              nodes_components.last << component
            else
              nodes_components << [component]
            end
          end
        end

        nodes_components.inject([]) do |nodes, node_or_component_group|
          if node_or_component_group.first.is_a?(Keisan::Parsing::Operator)
            node_or_component_group.each do |component|
              nodes << component
            end
          else
            nodes << node_from_components(node_or_component_group)
          end

          nodes
        end
      end

      def node_from_components(components)
        node, postfix_components = *node_postfixes(components)
        # Apply postfix operators
        postfix_components.each do |postfix_component|
          node = apply_postfix_component_to_node(postfix_component, node)
        end

        node
      end

      def apply_postfix_component_to_node(postfix_component, node)
        case postfix_component
        when Keisan::Parsing::Indexing
          postfix_component.node_class.new(
            node,
            postfix_component.arguments.map {|parsing_argument|
              Builder.new(components: parsing_argument.components).node
            }
          )
        when Keisan::Parsing::DotWord
          Keisan::AST::Function.new(
            [node],
            postfix_component.name
          )
        when Keisan::Parsing::DotOperator
          Keisan::AST::Function.new(
            [node] + postfix_component.arguments.map {|parsing_argument|
              Builder.new(components: parsing_argument.components).node
            },
            postfix_component.name
          )
        else
          raise Keisan::Exceptions::ASTError.new("Invalid postfix component #{postfix_component}")
        end
      end

      # Returns an array of the form
      # [node, postfix_operators]
      # middle_node is the main node which will be modified by prefix and postfix operators
      # postfix_operators is an array of Keisan::Parsing::Indexing, DotWord, and DotOperator objects
      def node_postfixes(components)
        index_of_postfix_components = components.map.with_index {|c,i| [c,i]}.select {|c,i|
          c.is_a?(Keisan::Parsing::Indexing) || c.is_a?(Keisan::Parsing::DotWord) || c.is_a?(Keisan::Parsing::DotOperator)
        }.map(&:last)
        unless index_of_postfix_components.reverse.map.with_index.all? {|i,j| i + j == components.size - 1 }
          raise Keisan::Exceptions::ASTError.new("postfix components must be in back")
        end

        num_postfix = index_of_postfix_components.size

        unless num_postfix + 1 == components.size
          raise Keisan::Exceptions::ASTError.new("have too many components")
        end

        [
          node_of_component(components[0]),
          index_of_postfix_components.map {|i| components[i]}
        ]
      end

      def node_of_component(component)
        case component
        when Parsing::Number
          AST::Number.new(component.value)
        when Parsing::String
          AST::String.new(component.value)
        when Parsing::Null
          AST::Null.new
        when Parsing::Variable
          AST::Variable.new(component.name)
        when Parsing::Boolean
          AST::Boolean.new(component.value)
        when Parsing::List
          AST::List.new(
            component.arguments.map {|parsing_argument|
              Builder.new(components: parsing_argument.components).node
            }
          )
        when Parsing::Hash
          AST::Hash.new(
            component.key_value_pairs.map {|key_value_pair|
              [
                Builder.new(components: [key_value_pair[0]]).node,
                Builder.new(components: key_value_pair[1].components).node
              ]
            }
          )
        when Parsing::RoundGroup
          Builder.new(components: component.components).node
        when Parsing::CurlyGroup
          Block.new(Builder.new(components: component.components).node)
        when Parsing::Function
          AST::Function.new(
            component.arguments.map {|parsing_argument|
              Builder.new(components: parsing_argument.components).node
            },
            component.name
          )
        when Parsing::DotWord
          AST::Function.new(
            [node_of_component(component.target)],
            component.name
          )
        when Parsing::DotOperator
          AST::Function.new(
            [node_of_component(component.target)] + component.arguments.map {|parsing_argument|
              Builder.new(components: parsing_argument.components).node
            },
            component.name
          )
        else
          raise Exceptions::ASTError.new("Unhandled component, #{component}")
        end
      end

      def consume_operators!
        loop do
          break if @priorities.empty?
          max_priority = @priorities.max
          break if max_priority < 0

          consume_operators_with_priority!(max_priority)
        end
      end

      def consume_operators_with_priority!(priority)
        p_indexes = @priorities.map.with_index.select {|p,index| p == priority}
        # :left, :right, or :none
        associativity = AST::Operator.associativity_of_priority(priority)

        if associativity == :right
          index = p_indexes[-1][1]
        else
          index = p_indexes[0][1]
        end

        operator = @nodes[index]

        # If has unary operators after, must process those first
        if @nodes[index+1].is_a?(Keisan::Parsing::UnaryOperator)
          loop do
            break if !@nodes[index+1].is_a?(Keisan::Parsing::UnaryOperator)
            index += 1
          end
          operator = @nodes[index]
        end

        # operator is the current operator to process, and index is its index
        if operator.is_a?(Keisan::Parsing::UnaryOperator)
          replacement_node = operator.node_class.new(
            children = [@nodes[index+1]]
          )
          @nodes.delete_if.with_index {|node, i| i >= index && i <= index+1}
          @priorities.delete_if.with_index {|node, i| i >= index && i <= index+1}
          @nodes.insert(index, replacement_node)
          @priorities.insert(index, -1)
        elsif operator.is_a?(Keisan::Parsing::Operator)
          replacement_node = operator.node_class.new(
            children = [@nodes[index-1],@nodes[index+1]],
            parsing_operators = [operator]
          )
          @nodes.delete_if.with_index {|node, i| i >= index-1 && i <= index+1}
          @priorities.delete_if.with_index {|node, i| i >= index-1 && i <= index+1}
          @nodes.insert(index-1, replacement_node)
          @priorities.insert(index-1, -1)
        else
          raise Keisan::Exceptions::ASTError.new("Can only consume operators")
        end
      end
    end
  end
end
