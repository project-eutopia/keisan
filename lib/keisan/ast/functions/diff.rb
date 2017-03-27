module Keisan
  module AST
    module Functions
      class Diff < AST::Function
        def value(context = nil)
          binding.pry
          raise Keisan::Exceptions::InvalidFunctionError.new("Derivative not defined")
        end

        def unbound_functions(context = nil)
          context ||= Keisan::Context.new

          children.inject(Set.new) do |res, child|
            res | child.unbound_functions(context)
          end
        end

        def simplify(context = nil)
          unless children.size > 0
            raise Keisan::Exceptions::InvalidFunctionError.new("Diff requires at least one argument")
          end

          children[1..-1].inject(children.first) do |result, var|
            result.differentiate(var)
          end
        end
      end
    end
  end
end
