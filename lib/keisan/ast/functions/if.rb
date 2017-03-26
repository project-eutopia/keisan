module Keisan
  module AST
    module Functions
      class If < AST::Function
        def value(context = nil)
          unless (2..3).cover? children.size
            raise Keisan::Exceptions::InvalidFunctionError.new("Require 2 or 3 arguments to if")
          end

          bool = children[0].value(context)

          if bool
            children[1].value(context)
          else
            children.size == 3 ? children[2].value(context) : nil
          end
        end

        def unbound_functions(context = nil)
          context ||= Keisan::Context.new

          children.inject(Set.new) do |res, child|
            res | child.unbound_functions(context)
          end
        end
      end
    end
  end
end
