module Keisan
  module AST
    module Functions
      class Diff < AST::Function
        def initialize(arguments, name = "diff")
          super(arguments, name)
        end

        def value(context = nil)
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

          vars = children[1..-1]

          unless vars.all? {|var| var.is_a?(AST::Variable)}
            raise Keisan::Exceptions::InvalidFunctionError.new("Diff must differentiate with respect to variables")
          end

          result = children.first.simplify(context)

          while vars.size > 0
            begin
              var = vars.first
              if result.unbound_variables(context).include?(var.name)
                result = result.differentiate(var, context)
              else
                return AST::Number.new(0)
              end
            rescue Keisan::Exceptions::NonDifferentiableError => e
              return AST::Functions::Diff.new(
                [result] + vars,
                "diff"
              )
            end

            vars.shift
          end

          result
        end
      end
    end
  end
end
