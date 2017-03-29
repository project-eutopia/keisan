module Keisan
  module AST
    class Builder
      # Build from parser
      def initialize(string: nil, parser: nil, components: nil)
        if [string, parser, components].select(&:nil?).size != 2
          raise Keisan::Exceptions::InternalError.new("Require one of string, parser or components")
        end

        if !string.nil?
          @components = Keisan::Parser.new(string: string).components
        elsif !parser.nil?
          @components = parser.components
        else
          @components = Array.wrap(components)
        end

        @nodes = components_to_basic_nodes(@components)

        # Negative means not an operator
        @priorities = @nodes.map {|node| node.is_a?(Keisan::Parsing::Operator) ? node.priority : -1}

        consume_operators!

        unless @nodes.count == 1
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
          if nodes_components.empty?
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
          Keisan::AST::Function.build(
            postfix_component.name,
            [node]
          )
        when Keisan::Parsing::DotOperator
          Keisan::AST::Function.build(
            postfix_component.name,
            [node] + postfix_component.arguments.map {|parsing_argument|
              Builder.new(components: parsing_argument.components).node
            }
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
        when Keisan::Parsing::Number
          Keisan::AST::Number.new(component.value)
        when Keisan::Parsing::String
          Keisan::AST::String.new(component.value)
        when Keisan::Parsing::Null
          Keisan::AST::Null.new
        when Keisan::Parsing::Variable
          Keisan::AST::Variable.new(component.name)
        when Keisan::Parsing::Boolean
          Keisan::AST::Boolean.new(component.value)
        when Keisan::Parsing::List
          Keisan::AST::List.new(
            component.arguments.map {|parsing_argument|
              Builder.new(components: parsing_argument.components).node
            }
          )
        when Keisan::Parsing::Group
          Builder.new(components: component.components).node
        when Keisan::Parsing::Function
          Keisan::AST::Function.build(
            component.name,
            component.arguments.map {|parsing_argument|
              Builder.new(components: parsing_argument.components).node
            }
          )
        when Keisan::Parsing::DotWord
          Keisan::AST::Function.build(
            component.name,
            [node_of_component(component.target)]
          )
        when Keisan::Parsing::DotOperator
          Keisan::AST::Function.build(
            component.name,
            [node_of_component(component.target)] + component.arguments.map {|parsing_argument|
              Builder.new(components: parsing_argument.components).node
            }
          )
        else
          raise Keisan::Exceptions::ASTError.new("Unhandled component, #{component}")
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
