module Keisan
  module AST
    module Functions
      class If < AST::Function
        def value(context = nil)
          unless (2..3).cover? children.size
            raise Keisan::Exceptions::InvalidFunctionError.new("Require 2 or 3 arguments to if")
          end

          context ||= Context.new

          bool = children[0].value(context)

          if bool
            children[1].value(context)
          else
            children.size == 3 ? children[2].value(context) : nil
          end
        end

        def simplify(context = nil)
          context ||= Context.new
          @children = children.map {|child| child.simplify(context)}

          if children[0].is_a?(AST::Boolean)
            if children[0].value
              children[1]
            else
              # If no third argument, then children[2] gives nil, and to_node makes this AST::Null
              children[2].to_node
            end
          else
            self
          end
        end

        def unbound_functions(context = nil)
          context ||= Context.new

          children.inject(Set.new) do |res, child|
            res | child.unbound_functions(context)
          end
        end
      end
    end
  end
end
