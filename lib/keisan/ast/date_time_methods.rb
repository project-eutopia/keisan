module Keisan
  module AST
    module DateTimeMethods
      def +(other)
        other = other.to_node
        case other
        when Number
          self.class.new(value + other.value)
        else
          super
        end
      end

      def >(other)
        other = other.to_node
        case other
        when self.class
          Boolean.new(value.to_time > other.value.to_time)
        else
          super
        end
      end

      def <(other)
        other = other.to_node
        case other
        when self.class
          Boolean.new(value.to_time < other.value.to_time)
        else
          super
        end
      end

      def >=(other)
        other = other.to_node
        case other
        when self.class
          Boolean.new(value.to_time >= other.value.to_time)
        else
          super
        end
      end

      def <=(other)
        other = other.to_node
        case other
        when self.class
          Boolean.new(value.to_time <= other.value.to_time)
        else
          super
        end
      end

      def equal(other)
        other = other.to_node
        case other
        when self.class
          Boolean.new(value.to_time == other.value.to_time)
        else
          super
        end
      end

      def not_equal(other)
        other = other.to_node
        case other
        when self.class
          Boolean.new(value.to_time != other.value.to_time)
        else
          super
        end
      end
    end
  end
end
